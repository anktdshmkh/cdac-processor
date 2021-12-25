-------------------------------------------------------------------------------
-- Title      : Source Code
-- Project    : Micro  Processor
-------------------------------------------------------------------------------
-- File       : PC_counter.vhd
-- Author     : Aniket Deshmukh <anktdshmkh@gmail.com>
-- Company    : 
-- Last update: 2006/06/21
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: This is a program counter circuit of processor. Operation of
-- this program counter is contrlled by jmp_cntrl and off_cntrl signals coming
-- from cntrl unit. According to status of that cntrl signals PC counter will
-- get loaded with perticular value like off_set+PC or [CD] i.e. memory
-- location pointed by C and D register. All operation are signed opertions i.e
-- PC can jump up or down according to off set specified in instructions.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/06/06  1.0      v1      Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

entity PC_Counter is
  port (
    clk       : in  std_logic;          -- clock for synchrnoization
    reset_a   : in  std_logic;          -- asyncronous reset
    Jmp_cntrl : in  std_logic;          -- Jmp control
    PC_CE     : in  std_logic;          -- PC clock enable
    Off_cntrl : in  std_logic;          -- Off set control
    off_set   : in  std_logic_vector (7 downto 0);  -- 8 bit immediate offset
    Mem_Add   : in  std_logic_vector (15 downto 0);  -- Memory address coming
                                                     -- from [CD]
    PC_out    : out std_logic_vector (15 downto 0)  -- Program counter output
    );

end PC_counter;

architecture PC_Counter_A of PC_counter is

  signal PC_reg   : std_logic_vector (15 downto 0);  -- PC register
  signal PC_in    : std_logic_vector (15 downto 0);  -- PC incremented result
  signal PC_temp  : std_logic_vector (15 downto 0);  -- Temp storage signals
  signal Off_temp : std_logic_vector (15 downto 0);  -- Temp off set addtion
  signal Jmp_addr : std_logic_vector (15 downto 0);  -- Final jump address

begin
  Main_Pro : process (clk, reset_a)
  begin
    if Reset_a = '1' then

      PC_reg <= (others => '0');

    elsif rising_edge(clk) then
      if PC_CE = '1' then
        PC_reg <= PC_in;
      end if;
    end if;

  end process Main_Pro;
  PC_temp  <= PC_reg + 1;
  Off_temp <= PC_reg + off_set;
  Jmp_addr <= off_temp when off_cntrl = '0' else Mem_add;
  PC_in    <= PC_temp  when jmp_cntrl = '0' else Jmp_addr;
  PC_out   <= PC_reg;
end PC_Counter_A;

configuration PC_Counter_C of PC_Counter is
  for PC_counter_A
  end for;
end PC_Counter_C;

