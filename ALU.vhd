-------------------------------------------------------------------------------
-- Title      : Source Code
-- Project    : Processor
-------------------------------------------------------------------------------
-- File       : ALU.vhd
-- Author     : Aniket Deshmukh  <anktdshmkh@gmail.com>
-- Company    : 
-- Last update: 2006/06/21
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: This is ALU circuit for performing simple operations like ADD,
-- INC, SUB, DEC, CMP....etc. It's a simple combinational circuit. 
-------------------------------------------------------------------------------
-- Revisions  : 
-- Date        Version  Author  Description
-- 2006/06/07  1.0      V1      Created
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
entity ALU is

  port (
    In_A   : in  std_logic_vector(7 downto 0);  -- 1 st input from Reg Bank
    In_B   : in  std_logic_vector(7 downto 0);  -- 2 nd input from Reg Bank (Reg A)
    Op_sel : in  std_logic_vector(3 downto 0);  -- I(9)&I(8)&I(7)&I(6)
    Flag   : out std_logic;                     -- Flag Output for ZERO Flag
    Dout   : out std_logic_vector(7 downto 0)   -- 8 bit ALU result out
    );

end ALU;

architecture ALU_A of ALU is

  signal ADD      : std_logic_vector(7 downto 0);  -- Addition signal for ADD
  signal SUB      : std_logic_vector(7 downto 0);  -- Subtraction signal for SUB
  signal PASS     : std_logic_vector(7 downto 0);  -- Pass signal for MOV instruction
  signal SL       : std_logic_vector(7 downto 0);  -- Shift left signal SL
  signal SR       : std_logic_vector(7 downto 0);  -- Shift right signal
  signal Dout_s   : std_logic_vector(7 downto 0);  -- Data out result of ALU
  signal Ad       : std_logic_vector(7 downto 0);  -- final reult for I9&I8="00"
  signal Sb       : std_logic_vector(7 downto 0);  -- final reult for I9&I8="01"
  signal Shift    : std_logic_vector(7 downto 0);  -- Final shift operation I9&I8="10"
  signal Sub_temp : std_logic_vector(7 downto 0);  -- Temp subtraction
  signal Cmp      : std_logic_vector(7 downto 0);  -- Cmp output (not result)
                                        -- used for Z flag generation
  signal Flag_s1  : std_logic;
  signal Flag_s2  : std_logic;


begin

  -- Addition Process (ADD, INC) Opcode: "00" (I(9)&I(8))
  Ad  <= In_B when Op_sel(0) = '0' else (0 => '1', others => '0');  -- if ADD then In_B else 1
  ADD <= In_A + Ad;

  -- Substraction Process (SUB, DEC, CMP) Opcode: "01" (I(9)&I(8))
  Sb       <= In_B     when Op_sel(0) = '0'            else (0                => '1', others => '0');  -- if SUB then In_B else 1
  SUB_temp <= In_A - Sb;
  Cmp      <= Sub_temp when Op_sel(3 downto 1) = "011" else (0 => '1', others => '0');
  SUB      <= Sub_temp when Op_sel(3 downto 1) = "010" else (0 => '1', others => '0');

  -- Shift Process (SH, SL) Opcode: "10" (I(9)&I(8))  -- 
  SL    <= In_A(6 downto 0)&'0';
  SR    <= '0'&In_A(7 downto 1);
  Shift <= SL when Op_sel(0) = '0'else SR;

  -- Move Instruction (MOV) Opcode: "11" (I(9)&I(8))
  PASS <= In_A;


  -- Final MUX for ALU  operation using Op_sel
  Main_Pro_P : process (Op_sel, ADD, SUB, Shift, PASS)

  begin
    case Op_sel(3 downto 1) is          -- Instruction (I(9)&I(8))
      when "001"  => Dout_s <= ADD;
      when "010"  => Dout_s <= SUB;
      when "100"  => Dout_s <= Shift;
      when "110"  => Dout_s <= PASS;
      when "111"  => Dout_s <= PASS;
      when others => Dout_s <= (0 => '1', others => '0');
                     -- "00000001" for not affecting flag when any other instruction comes
    end case;
  end process Main_Pro_P;

-- Comparision Process for All operation including CMP
  CMP_Pro_P : process (Dout_s, Cmp)
  begin
    if (Dout_s = "00000000") then       -- Flag_s1 for All other instructions
      Flag_s1 <= '1';
    else
      Flag_s1 <= '0';
    end if;
    if (Cmp = "00000000") then          -- Flag_s2 for CMP
      Flag_s2 <= '1';
    else
      Flag_s2 <= '0';
    end if;
  end process CMP_Pro_P;

  Flag <= (Flag_s1 or Flag_s2);         -- Final Flag output
  Dout <= Dout_s;

end ALU_A;

configuration ALU_C of ALU is
  for ALU_A
  end for;
end ALU_C;



