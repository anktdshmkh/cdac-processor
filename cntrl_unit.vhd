-------------------------------------------------------------------------------
-- Title      : Source Code for Control Unit
-- Project    : Processor
-------------------------------------------------------------------------------
-- File       : cntrl_unit.vhd
-- Author     : Aniket Deshmukh  <anktdshmkh@gmail.com>
-- Company    : 
-- Last update: 2006/06/21
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: This is control unit for processor to generate differnt control
-- signals like destination select signal, register write enable signal, jmp
-- control, off set value control, ALU operation control signals, Memory read
-- and Memory write signals and program counter clock enable signal. This is
-- combination circuit based on instruction decoding
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/06/08  1.0      V1      Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity cntrl_unit is

  port (
    Ins       : in std_logic_vector(10 downto 0);  -- Instruction word
    Z_flag_in : in std_logic;                      -- Zero flag input

    dst_sel : out std_logic_vector(4 downto 0);  -- destination select
    sr_sel  : out std_logic_vector(2 downto 0);  -- source select
    reg_wr  : out std_logic;                     -- Register write enable

    flag_cntrl : out std_logic;                     -- Flag Control 
    Alu_sel    : out std_logic_vector(3 downto 0);  -- ALU opcode output

    jmp_cntrl : out std_logic;          -- jmp instruction control
    off_cntrl : out std_logic;          -- immediate offset control for
                                        -- immediate instruction

    load_cntrl : out std_logic;         -- load instruction control
    str_cntrl  : out std_logic;         -- store instruction control

    Imm_cntrl : out std_logic;          -- Immediate data control for mvi instruction

    mem_rd : out std_logic;             -- Memory read signal
    mem_wr : out std_logic;             -- Memory write signal
    PC_CE  : out std_logic              -- PC clock enable for hlt instruction 
    );

end cntrl_unit;

architecture cntrl_unit_A of cntrl_unit is
  signal Ins_s : std_logic_vector(10 downto 0);
  signal Z_s   : std_logic;
begin
  Ins_s   <= Ins;
  Z_s     <= Z_flag_in;
  Alu_sel <= Ins_s(9 downto 6);         -- Op code ADD,SUB,SHIFT,PASS

  sr_sel     <= Ins_s(2 downto 0);      -- RegA, RegB, RegC, RegD, Xin
  dst_sel(0) <= '1' when (Ins_s(5 downto 3) = "001" or Ins_s(10 downto 8) = "110") else '0';  -- For RegA
  dst_sel(1) <= '1' when (Ins_s(5 downto 3) = "010" and Ins_s(10 downto 8)/="110") else '0';  -- For RegB
  dst_sel(2) <= '1' when (Ins_s(5 downto 3) = "011" and Ins_s(10 downto 8)/="110") else '0';  -- For RegC
  dst_sel(3) <= '1' when (Ins_s(5 downto 3) = "100" and Ins_s(10 downto 8)/="110") else '0';  -- For RegD
  dst_sel(4) <= '1' when (Ins_s(5 downto 3) = "101" and Ins_s(10 downto 8)/="110") else '0';  -- For Xout

  -- Wr_en for All registers '0' for jmpi, jz, cmp, store, hlt, NOP instructions
  Reg_wr     <= '0' when (Ins_s(10 downto 6) = "00110" or Ins_s(10 downto 6) = "01101" or Ins_s(10 downto 6)="00000"
                          or Ins_s(10 downto 8) = "100" or Ins_s(10 downto 8) = "101" or Ins_s(10 downto 8) = "111")
                else '1';
  
  -- Flag_cntrl '0' for all immediate instruction or group IV instructions
  flag_cntrl <= '0' when (Ins_s(10) = '1' or Ins_s(9 downto 8) = "11" )
                else '1';

  -- PC related control signals
  Jmp_cntrl <= '1' when (Ins_s(9 downto 6) = "1101" or Ins_s(10 downto 8)&Z_s = "1011" or Ins_s(10 downto 8) = "100")
               else '0';
  off_cntrl <= '1' when (Ins_s(10 downto 6) = "01101")  -- off set control for JZ and JMPi instructions
               else '0'; 
  PC_CE     <= '0' when (Ins_s(10 downto 8) = "111")    -- for HLT instruction
               else '1';
  
  -- Data Memroy related control signals
  Imm_cntrl  <= '1' when (Ins_s(10 downto 8)) = "110" else '0';
  load_cntrl <= '1' when Ins_s(10 downto 6) = "01110" else '0';  -- for LOAD instruction
  str_cntrl  <= '1' when Ins_s(10 downto 6) = "01111" else '0';  -- for STORE instruction

  mem_rd <= '1' when Ins_s(10 downto 6) = "01110" else '0';  -- for LOAD instruction
  mem_wr <= '1' when Ins_s(10 downto 6) = "01111" else '0';  -- for STORE instruction

end cntrl_unit_A;

configuration cntrl_unit_C of cntrl_unit is
  for cntrl_unit_A 
  end for;
end cntrl_unit_C;
