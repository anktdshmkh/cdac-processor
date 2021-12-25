-------------------------------------------------------------------------------
-- Title      : Source Code
-- Project    : Processor Design
-------------------------------------------------------------------------------
-- File       : Reg_bank.vhd
-- Author     : Aniket Deshmukh  <anktdshmkh@gmail.com>
-- Company    : 
-- Last update: 2006/06/21
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: This is a register bank with Xin and Xout as input and output
-- ports respectively, According to sel register or port is selected and will
-- get available on Dout1 while Dout2 will alway be RegA. Mem_add is nothing
-- but concatination of RegC and RegD where RegC is MSB to address external
-- data memory. Wr_en, CE, sel signals are coming from control unit. Clock and
-- Reset are providied for synchronization and initialization respectively.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/06/07  1.0      V1      Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Reg_bank is

  port (     Din     : in  std_logic_vector(7 downto 0);  -- Data input for Write into Regs
             Xin     : in  std_logic_vector(7 downto 0);  -- 8 bit input port (Xin)
             clk     : in  std_logic;   -- Clock input for Synchronization
             reset_a : in  std_logic;   -- Asynchronous Reset 
             Wr_en   : in  std_logic;   -- Write enable to Write into Regs
             CE      : in  std_logic_vector(4 downto 0);  -- Clock enable for each Reg
             sel     : in  std_logic_vector(2 downto 0);  -- Select input for Dout1
             Dout1   : out std_logic_vector(7 downto 0);  -- 1st 8 bit data out
             Dout2   : out std_logic_vector(7 downto 0);  -- 2nd 8 bit data out
             Xout    : out std_logic_vector(7 downto 0);  -- 8 bit output port (Xout)
             Mem_add : out std_logic_vector(15 downto 0)  -- Data memory address
                                        -- output for  [CD]
             );
end Reg_bank;

architecture Reg_bank_A of Reg_bank is
-- Register Declearation
  signal RegA : std_logic_vector(7 downto 0);
  signal RegB : std_logic_vector(7 downto 0);
  signal RegC : std_logic_vector(7 downto 0);
  signal RegD : std_logic_vector(7 downto 0);
  signal RegX : std_logic_vector(7 downto 0);
  signal CE_s : std_logic_vector(4 downto 0);

begin

-- Write process for register and port (Destination Selection)
  Main_Pro_P : process (clk, reset_a)
  begin
    if (reset_a = '1') then

      RegA <= (others => '0');
      RegB <= (others => '0');
      RegC <= (others => '0');
      RegD <= (others => '0');
      RegX <= (others => '0');
      
    elsif rising_edge(clk) then
      if CE_s(0) = '1' then
        RegA <= Din;
      end if;
      if CE_s(1) = '1' then
        RegB <= Din;
      end if;
      if CE_s(2) = '1' then
        RegC <= Din;
      end if;
      if CE_s(3) = '1' then
        RegD <= Din;
      end if;
      if CE_s(4)='1' then
        RegX <= Din;
      end if;
    end if;

  end process Main_Pro_P;

-- Register and Port selection process (Source Selection)
  Reg_Out_P : process (Sel, RegA, RegB, RegC, RegD, Xin)
  begin
    case Sel is
      when "001"  => Dout1 <= RegA;
      when "010"  => Dout1 <= RegB;
      when "011"  => Dout1 <= RegC;
      when "100"  => Dout1 <= RegD;
      when "101"  => Dout1 <= Xin;
      when others => Dout1 <= (others => '0');
    end case;
  end process Reg_out_P;

-- Clock enable with Write enable
  CE_s(0) <= CE(0) and Wr_en;
  CE_s(1) <= CE(1) and Wr_en;
  CE_s(2) <= CE(2) and Wr_en;
  CE_s(3) <= CE(3) and Wr_en;
  CE_s(4) <= CE(4) and Wr_en;

-- Output assignments
  Xout    <= RegX;
  Dout2   <= RegA;
  Mem_add <= RegC&RegD;

end Reg_bank_A;

configuration Reg_Bank_C of Reg_bank is
  for Reg_Bank_A
  end for;
end Reg_Bank_C;
