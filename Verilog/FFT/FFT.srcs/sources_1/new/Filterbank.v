`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03/01/2026 04:03:10 PM
// Design Name:
// Module Name: Filterbank
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module Filterbank(
  input clk,
  input [15:0] sample,
  input rst



    );


//FSM: resetnél feltölteni 512 elemmel
localparam [1:0] BEGIN = 2'b00;
localparam [1:0] SAMPLE_IN = 2'b01;
localparam [1:0] CALC_SAMPLES = 2'b10;

reg [1:0] state_reg;
reg [8:0] input_sample_count;
reg sample_write_en;
reg [8:0] sample_write_addr;
reg [8:0] sample_read_addr;
wire [15:0] sample_to_mul;
reg [4:0] sample_shift_cntr;


reg [8:0] c_coeff_read_addr;



always @ (posedge clk) begin
  if (rst == 1) begin
    state_reg <= BEGIN;
    input_sample_count <= 0;
    sample_write_en <= 0;
    sample_write_addr <= 0;
    sample_read_addr <= 0;
    sample_shift_cntr <= 0;
    c_coeff_read_addr <= 0;


  end else begin
    case(state_reg)
      BEGIN: begin

        if (input_sample_count == 511) begin
          state_reg <= CALC_SAMPLES;
          sample_write_en <= 0;
          input_sample_count <= 0;
          sample_read_addr <= sample_write_addr; // már itt meg kell csinálni, hogy szinkronban legyen a c_coeffekkel
        end

        else begin
          state_reg <= BEGIN;
          sample_write_en <= 1;

          if(sample_write_en == 1)
          begin
            input_sample_count <= input_sample_count + 1;
            sample_write_addr <= sample_write_addr + 1;
          end

        end

      end

      SAMPLE_IN: begin

        if (sample_shift_cntr == 31) begin
          state_reg <= CALC_SAMPLES;
          sample_shift_cntr <= 0;
          sample_write_en <= 0;
          sample_read_addr <= sample_write_addr - (input_sample_count + 1); // már itt meg kell csinálni, hogy szinkronban legyen a c_coeffekkel
          input_sample_count <= input_sample_count + 1;
        end
      // 

        else begin
          state_reg <= SAMPLE_IN;
          sample_shift_cntr <= sample_shift_cntr + 1;
          sample_write_addr <= sample_write_addr + 1;
          sample_write_en <= 1; // ezt meghagyjam itt átláthatóság miatt? Már engedélyezve van...
          end

      end

      // kell egy számláló, ennek az értékét vonom ki mindig egy
      // változóból, amiben az 511 - offset van, és ez az aktuális címem



      CALC_SAMPLES: begin

        if (input_sample_count == 511) begin
          state_reg <= SAMPLE_IN;
          sample_write_en <= 1; //időzítés miatt már itt engedélyezni kell, hogy a következő órajelben már a megfelelő értéket írjam a BRAM-ba
          input_sample_count <= 0;
          c_coeff_read_addr <= 0;
          sample_write_addr <= sample_write_addr + 1; // következő írás kezdeténél ne a legutóbb beírt utolsó mintát írja felül
        end

        else begin
          state_reg <= CALC_SAMPLES;
          input_sample_count <= input_sample_count + 1;
          sample_read_addr <= sample_write_addr - (input_sample_count + 1);
          c_coeff_read_addr <= c_coeff_read_addr + 1;
        end



      end


    default: begin
      state_reg <= SAMPLE_IN;
      input_sample_count <= 0;
    end

  endcase
  end




end

wire signed [31:0] c_coeff;


c_coeff_rom_512x32 c_coeff_rom(
  .clk(clk),
  .addr(c_coeff_read_addr),
  .dout(c_coeff)
);

ram
#
(
  .DATA_W(16),
  .ADDR_W(9)
)sample_ram
(
  .clk_a(clk),
  .we_a(sample_write_en),
  .addr_a(sample_write_addr),
  .din_a(sample),
  .dout_a(),

  .clk_b(clk),
  .we_b(0),
  .addr_b(sample_read_addr),
  .din_b(),
  .dout_b(sample_to_mul)
);
wire [58:0] c_mul_res;

mul_24x35 mul_sample_and_coeff_c(
  .clk(clk),
  .a({{8{sample_to_mul[15]}}, sample_to_mul}),
  .b({{3{c_coeff[31]}}, c_coeff}),
  .m(c_mul_res) // ezt még vissza kell shiftelni (vagy csak wire-ban azokat a jeleket használni...)
);
//31 bittel vissza kell shiftelni, mivel 2^31-el szoroztam az együtthatókat,
//amikor megadtam azokat a ROM-ba
//c_mul_res[47:31] //32+16=48 48-31=17 17 bites eredményt várok
//lehet mielőtt a kövi részt is megcsinálom, ezt le kéne ellenőrizni...

//Egy RAM kéne, amibe eltárolok 64 szorzás eredményt, hogy össze tudjam adni
//őket... várjunk csak, ez egy konvolúció nem? Ezt a lépést meg tudnám
//csinálni egyben? Szorzok, és hozzáadom az előzőt, igen ez egy
//konvolúció

// csak annyival shiftelek vissza, hogy 24 bites eredményem legyen, és számon
// tartom, hogy Q17.7-es a számábrázolásom

// Y számítása (c_mul_res = Z_i)
//64 db eredmény, felosztjuk az 512 eredményt 64-re, ahol Y_0 minden szegmens
//0-ik eleme, Y_1 minden szegmens 1. eleme...
//Ezzel tömörítjük az adatot, és aliasolunk direkt
//Visszaállításnál elvben az átlapolódó részek kioltják majd egymást

reg [61:0] y_res;
reg [61:0] y_new_sum;
wire [61:0] y_old_sum;
reg [5:0] y_en;
reg [5:0] y_addr_wr;
reg [5:0] y_addr_rd;

ram
#
(
  .DATA_W(62),
  .ADDR_W(6)
)y_ram
(
  .clk_a(clk),
  .we_a(y_en[5]),
  .addr_a(y_addr_wr),
  .din_a(y_new_sum),
  .dout_a(),

  .clk_b(clk),
  .we_b(0),
  .addr_b(y_addr_rd),
  .din_b(),
  .dout_b(y_old_sum)
);
//448 szorztanál már elkezdhetem a mátrixolást, a kérdés az, hogy mennyire
//bonyolítja meg, hogy  akkor még dolgozom föl a többi y értéket is... olyan
//szempontból nem baj, hogy minden clk-ra a következő Y érték el fog készülni
//csak oda kell figyelni az időzítésre az olvasásnál

//ki kéne számolni, hogy mennyi időm van a feldolgozásra, mennyi idő alatt jön
//be 32 minta, mivel ennyi idő alatt el kell készülnöm az egész folyamattal
//f_s = 44.1kHz -> T_s = 22.67 us, 32*T_s = 725.44 us
//clk = 100MHz, egy szorzás 1 clk -> T_clk = 10ns
//mielőtt megkezdhetném a mátrixolást az ablakolásnak és az Y-ok összeadásának
//el kell készülnie, ez jelenleg: 512 szorzás (512 clk), miközben ezek
//készülnek el, csinálhatom a részösszeadásokat is, szóval az nem extra idő
//Akkor, mire elkezdhetem a mátrixolást 5.12 us telt el, marad rá ~720us
//Ja várjunk, annyi időm van, amíg 1 minta bejön, nem ameddig 32, szóval ~17
//us-em van, de az is 17000clk
//Valószínűleg nem kell elkezdenem 448 nál és akkor kevésbé bonyolodok bele,
//feltölthetem az egész 64 Y értékeket mielőtt hozzálátok


// egyszerűen, ha a címszámlálót úgy növelem, ahogy jönnek be a minták, akkor
// jól fogja összeadni őket, mindegyik indexre 8 darab, 64-el eltolt szorzat
// lesz összeadva

// engedélyező jelhez azt kell megnéznem, hogy mikor kezdődik el a minták
// feldolgozása, és ehhez képest mikor lesz készen az első szorzat 
// 1clk a BRAM-ból kiolvasni, hogy mit szorozzon és a DSP 4 clk alatt lesz kész a szorzással
// szóval onnantól, hogy CALC_SAMPLES-be léptünk, 5 clk, mire lesz kész
// szorzatunk
// A 4.clk-ban kezdeményeznem kell az y_ram olvasást, hogy az 5.re készen
// legyen (igazábol nem biztos, mert az első úgyis 0 és útána amikor elkezdem
// az összeadásokat, akkor amikor egyet beírok, már egyből olvasom ki
// a következő címen léveő értéket, szóval a következő órajelre már készen fog
// állni
// Tehát, a lényeg, hogy 5clk mire lesz szorzat, és 1 clk, mire elvégzem az
// összeadást, tehát 6clk-val megkésleltetve néznem, hogy mikor vagyunk
// a CALC_SAMPLE állatpotban

always @ (posedge clk)
begin
    y_en <=  {y_en[4:0], (state_reg == CALC_SAMPLES)};
end

 
always @ (posedge clk)
begin
  if(rst)
  begin
    y_addr_wr <= 0;
    y_addr_rd <= 0;
    y_new_sum <= 0;
  end
  // itt még valami olvasásos időzítés lehet nem jó...
  if (y_en[4])
    begin
      y_new_sum <= c_mul_res + y_old_sum;
      y_addr_wr <= y_addr_rd;
      y_addr_rd <= y_addr_rd + 1;
    end
end

reg [2:0] y_ready_cntr;

always @ (posedge clk)
begin
  if(rst)
    y_ready_cntr <= 0;

  else if(y_addr_rd == 63)
    y_ready_cntr <= y_ready_cntr + 1;
end

// miközben számítom ki a szorzatokat, közben adogathatom össze az y-okat is.
// Az a baj, hogy az első 448 szorzatnak készen kell lennie, hogy az y-okat el
// tudjam kezdeni feldolgozni...
// Opció1: folyamatosan dolgozom fel az y-okat ahogy készülnek el a szorzatok,
// és eltárolom őket egy BRAM-ban, majd ebből mátrixolok
// Nagyon más opció nincs is, mert a következő lépéshez a kész Y-ok kellenek,
// az y részeredmények nem hasznosak



//Matrixing
//reg [10:0] matrix_coeff_addr;
//wire signed [31:0] matrix_coeff;
//
//matrix_coeff_rom matrix_coeff_rom(
//  .clk(clk),
//  .addr(matrix_coeff_addr),
//  .dout(matrix_coeff)
//);
//
//mul_24x35 matrixing(
//  .clk(clk),
//  .a({accu[22],accu[22:0]}),
//  .b({{3{matrix_coeff[31]}}, matrix_coeff}),
//  .m(matrix_mul_res)
//);
//
//
//
//
//always @ (posedge clk)
//begin
//  if(rst_n == 0)
//  begin
//  end
//
//  else
//  begin
//    if(accu_cntr == 63)
//    begin
//      matrix_coeff <= matrix_coeff + 1;
//    end
//  end
//
//end


//C kóddal legenerálni az M_ik mátrixot, ROM-ba rakni az értékeket

//M_ik = cos [(2i + 1)(k - 16)pi/64], for i = 0...31 and k = 0...63



endmodule
