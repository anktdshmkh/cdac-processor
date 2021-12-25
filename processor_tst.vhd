-------------------------------------------------------------------------------
-- Title      : Test Bench of processor
-- Project    : Processor
-------------------------------------------------------------------------------
-- File       : processor_tst.vhd
-- Author     : Aniket  <anktdshmkh@gmail.com>
-- Company    : 
-- Last update: 2006/06/21
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: This is test bench for testing function of processor here
-- instructions are read from "program.txt" text file with help of function f_
-- con assembly code is converted in to machine code. f_con is written in package.
-- vhd. It works as assembler. With the help of Model Sim Utility SPY it's
-- possible to monitor internal registers in wave forms. Due to this  internal
-- value of these register also possible to be written on to console. Read_from_
-- file procedure reads all instructions at a single time only. Hex_return is
-- used from cpu_pack for converting byte into it's hex value.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/06/10  1.0      V1      Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_textio.all;
use work.cpu_pack.all;
use std.textio.all;
library modelsim_lib;
use modelsim_lib.util.all;

entity processor_tst is
  
  type mem is array (0 to 65535) of std_logic_vector(7 downto 0);    
  shared variable data_mem : mem;       -- data memory
  
end processor_tst;

architecture processor_tst_A of processor_tst is

-------------------------------------------------------------------------------
-- type declaration.
-------------------------------------------------------------------------------

  type data is record
                 op_code : string (1 to 9);
  end record;
 
  type data_array is array (natural range <>) of data;
-------------------------------------------------------------------------------
--Procedure to read from file
-------------------------------------------------------------------------------
    procedure read_from_file ( data_rd   : inout data_array;
                               file_name : in  string;
                               no_read   : out integer) is
   file data_file : text open read_mode is file_name;
   variable rline : line;
   variable wline : line;
   variable g_val : boolean;
   variable i     : integer := 0;
  begin  -- read_from_file
    readline(data_file,rline);
   Loop1_W: while not endfile(data_file) loop
      readline(data_file,rline);
      read(rline,data_rd(i).op_code,g_val);
      if (data_rd(i).op_code(1)='#') then
        i := i ;
        next;
      else
        assert g_val
          report "Invalid Op code from file READ ERROR"
          severity Note;
          i := i + 1;
      end if;
    end loop Loop1_W;
      no_read := i - 1;
  end read_from_file;
  
-----------------------------------------------------------------------------
  
  type inst_mem is array (0 to 65535) of std_logic_vector(10 downto 0);  --instruction memory array
 
  constant clk_prd : time := 100 ns;                       -- clock period
  signal clk       : std_logic                    := '0';  -- clock input.  
  signal rst       : std_logic                    := '1';  -- to reset the processor.
  
  signal Xin_s     : std_logic_vector(7 downto 0) := (0 => '1',others => '0');  -- to give Xin input from the peripharal device.
  signal Xout_S    : std_logic_vector(7 downto 0);  -- to extract Xout from the processor.
  signal rd_s      : std_logic;                     -- to extract read signal from the processor.
  signal wr_s      : std_logic;                     -- to extract write signal from the processor.
  signal data_s    : std_logic_vector(7 downto 0) := (others => '0');  -- to take data from or to the data mem.
  signal pc_s      : std_logic_vector(15 downto 0);  -- address from PC.
  signal addr_s    : std_logic_vector(15 downto 0);  -- address to the data memory.
  signal code      : std_logic_vector(10 downto 0) := (others => '0');  
                                                  -- to pass instruction code to the processor.
  
  --  Spy Signals
  signal Z_flag : std_logic;            -- for Z flag output
  signal regA   : std_logic_vector(7 downto 0);  -- Register A
  signal regB   : std_logic_vector(7 downto 0);  -- Register B
  signal regC   : std_logic_vector(7 downto 0);  -- Register C
  signal regD   : std_logic_vector(7 downto 0);  -- Register D
  signal Z_cntrl : std_logic;           -- Status of Z flag CE signal

-------------------------------------------------------------------------------
-- component declaration.
-------------------------------------------------------------------------------
  component processor
    port (
      ins  : in    std_logic_vector(10 downto 0);
      clk  : in    std_logic;
      rst  : in    std_logic;
      Xin  : in    std_logic_vector(7 downto 0);
      Data : inout std_logic_vector(7 downto 0);
      rd   : out   std_logic;
      wr   : out   std_logic;
      addr : out   std_logic_vector(15 downto 0);
      pc   : out   std_logic_vector(15 downto 0);
      Xout : out   std_logic_vector(7 downto 0));
  end component;
-------------------------------------------------------------------------------  

begin  -- processor_tst_A  

  processor_U : processor   
    port map (
      ins  => code,
      clk  => clk,
      rst  => rst,
      Xin  => Xin_s,
      Data => Data_s,
      rd   => rd_s,
      wr   => wr_s,
      addr => addr_s,
      pc   => pc_s,
      Xout => Xout_s);

      clk <= not clk after clk_prd/2;   -- clock signal generation
  -- Model Sim Spy utility
    init_signal_spy("processor_U/reg_Bank_U1/regA", "RegA");  -- for RegA
    init_signal_spy("processor_U/reg_Bank_U1/regB", "RegB");  -- For RegB
    init_signal_spy("processor_U/reg_Bank_U1/regC", "RegC");  -- For RegC
    init_signal_spy("processor_U/reg_Bank_U1/regD", "RegD");  -- For RegD
    init_signal_spy("processor_U/Z_flag", "Z_flag");
    init_signal_spy("processor_U/flag_CE","Z_cntrl");  
  
  
Main_Pro_P:  process


       variable no_ins   : integer;                                    -- number of instructions
       variable instr    : inst_mem := (others => (others => '0'));    -- instruction set.
       variable ins_rd   : data_array (0 to 500);                      -- total instructions
       variable count    : integer := 1;
       variable wline    : line;
  begin
    if count=1 then
        read_from_file ( data_rd   => ins_rd,
                         file_name => "program1.txt",  -- file name in which program is stored
                         no_read   => no_ins);
        count := 0;
   else
      
     for i in 0 to no_ins loop          -- storing instructions in to instruction mem
       instr(i) :=  f_con(ins_rd(i).op_code);
     end loop;  -- i
    
     wait until clk = '0';
     rst <= '0';
     if wr_s = '1' then                 -- if write is asserted then data will
                                        -- be written into data memory
      data_mem(conv_integer(addr_s)) := data_s;
     else      
      data_s <= (others => 'Z');  
     end if;
    
     code <= instr(conv_integer(pc_s));  -- code assignment according to program counter
     wait until clk='1';
     -- writing status of all registers on console
     write(wline, string'("Value of reg. A "));
     write(wline, regA);
     write(wline, string'(" ") & "(" & hex_ret(regA(7 downto 4))& hex_ret(regA(3 downto 0)) &"h"& ")" );
     writeline(output, wline);
     write(wline, string'("Value of reg. B "));
     write(wline, regB);
     write(wline, string'(" ") & "(" & hex_ret(regB(7 downto 4))& hex_ret(regB(3 downto 0)) &"h"& ")" );
     writeline(output, wline);
     write(wline, string'("Value of reg. C "));
     write(wline, regC);
     write(wline, string'(" ") & "(" & hex_ret(regC(7 downto 4))& hex_ret(regC(3 downto 0)) &"h"& ")" );
     writeline(output, wline);
     write(wline, string'("Value of reg. D "));
     write(wline, regD);
     write(wline, string'(" ") & "(" & hex_ret(regD(7 downto 4))& hex_ret(regD(3 downto 0)) &"h"& ")" );
     writeline(output, wline);
     write(wline, string'("Value at Xout   "));
     write(wline, Xout_s);
     write(wline, string'(" ") & "(" & hex_ret(Xout_s(7 downto 4))& hex_ret(Xout_s(3 downto 0)) &"h"& ")" );
     writeline(output, wline);
     write(wline, string'("Status of Zero Flag Register "));
     write(wline, Z_flag);
     write(wline, string'(" ") & "(" & std_logic'image(Z_flag) & ")" );
     writeline(output, wline);
     writeline(output, wline);
   end if;
  
  end process Main_Pro_P;
       
--Data memory read process
Read_Mem_P: process(rd_s)

  begin  -- process

    if rd_s = '1' then
      data_s <= data_mem(conv_integer(addr_s));
    else
      data_s <= (others => 'Z');
    end if;
  
  end process Read_Mem_P;
  


 

end processor_tst_A;
