-------------------------------------------------------------------------------
-- Title      : Source Code Main Code
-- Project    : Processor
-------------------------------------------------------------------------------
-- File       : processor.vhd
-- Author     : Aniket  <anktdshmkh@gmail.com>
-- Company    : 
-- Last update: 2006/06/21
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: This is the main processor unit which includes all cntrol, ALU
-- and PC Counter units. Interfaced with each other.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/06/08  1.0      V1      Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Processor is

   port (
      rst : in std_logic;               -- asynchronous Reset signal
      clk : in std_logic;               -- clock signal for synchronization

      Xin : in std_logic_vector(7 downto 0);  -- 8 bit Xin input port
      ins : in std_logic_vector(10 downto 0);  -- Instruction word coming from instruction memory 

      data : inout std_logic_vector(7 downto 0);  -- bidirectional data bus for data memory
      addr : out   std_logic_vector(15 downto 0);  -- Memory address output

      rd   : out std_logic;             -- Data Memory Read output
      wr   : out std_logic;             -- Data memory Write output
      pc   : out std_logic_vector(15 downto 0);  -- 16 bit Programm counter output
      Xout : out std_logic_vector(7 downto 0)  -- 8 bit Xout output port
      );

end Processor;

architecture Processor_A of Processor is
-------------------------------------------------------------------------------
-- component instantiation
-------------------------------------------------------------------------------
   component Cntrl_Unit
      port (
         Ins        : in  std_logic_vector(10 downto 0);  -- Instruction Word
         Z_flag_in  : in  std_logic;                      -- X Flag input
         dst_sel    : out std_logic_vector(4 downto 0);   -- destination select
         sr_sel     : out std_logic_vector(2 downto 0);   -- source select
         reg_wr     : out std_logic;                      -- Register write enable
         Alu_sel    : out std_logic_vector(3 downto 0);   -- ALU opcode output
         jmp_cntrl  : out std_logic;
         flag_cntrl : out std_logic;
         off_cntrl  : out std_logic;
         load_cntrl : out std_logic;
         str_cntrl  : out std_logic;
         Imm_cntrl  : out std_logic;
         mem_rd     : out std_logic;
         mem_wr     : out std_logic;
         PC_CE      : out std_logic
         );

   end component;

   component ALU
      port (
         In_A   : in  std_logic_vector(7 downto 0);
         In_B   : in  std_logic_vector(7 downto 0);
         Op_sel : in  std_logic_vector(3 downto 0);
         Flag   : out std_logic;
         Dout   : out std_logic_vector(7 downto 0));
   end component;

   component Reg_bank
      port (
         Din     : in  std_logic_vector(7 downto 0);
         Xin     : in  std_logic_vector(7 downto 0);
         clk     : in  std_logic;
         reset_a : in  std_logic;
         Wr_en   : in  std_logic;
         CE      : in  std_logic_vector(4 downto 0);
         sel     : in  std_logic_vector(2 downto 0);
         Dout1   : out std_logic_vector(7 downto 0);
         Dout2   : out std_logic_vector(7 downto 0);
         Xout    : out std_logic_vector(7 downto 0);
         Mem_add : out std_logic_vector(15 downto 0));
   end component;

   component PC_Counter
      port (
         clk       : in  std_logic;
         reset_a   : in  std_logic;
         Jmp_cntrl : in  std_logic;
         Off_cntrl : in  std_logic;
         PC_CE     : in  std_logic;
         off_set   : in  std_logic_vector (7 downto 0);
         Mem_Add   : in  std_logic_vector (15 downto 0);
         PC_out    : out std_logic_vector (15 downto 0));
   end component;



   signal Reg_Din      : std_logic_vector(7 downto 0);  -- Register bank Input from MUX
   signal ALU_out      : std_logic_vector(7 downto 0);  -- ALU result
   signal Reg_out1     : std_logic_vector(7 downto 0);  -- Reg Bank output1 to ALU
   signal Reg_out2     : std_logic_vector(7 downto 0);  -- Reg Bank output2 to ALU (REG A)
   signal Op_code      : std_logic_vector(3 downto 0);  -- Op code from cntrl unit to ALU 
   signal dst_sel      : std_logic_vector(4 downto 0);  -- Destination select from Cntrl to Reg_bank
   signal src_sel      : std_logic_vector(2 downto 0);  -- Source select from cntrl to Reg_bank
   signal Mem_add_s    : std_logic_vector(15 downto 0);  -- Memory address output i.e. [CD]
   signal Imm_data     : std_logic_vector(7 downto 0);  -- Immediate data
   signal Data_1       : std_logic_vector(7 downto 0);  -- for Mux operation*
   signal Data_2       : std_logic_vector(7 downto 0);  -- for MUX operation**
   signal jmp_cntrl_s  : std_logic;     -- jump control for PC_Counter from cntrl unit
   signal off_cntrl_s  : std_logic;     -- Off set control for PC from cntrl unit
   signal load_cntrl_s : std_logic;     -- load cntrl from cntrl unit
   signal str_cntrl_s  : std_logic;     -- store cntrl from cntrl unit
   signal Imm_cntrl_s  : std_logic;     -- Immediate data control signal
   signal Flag_CE      : std_logic;     -- flag chip enable
   signal Z_Flag       : std_logic;     -- Zero FLAG
   signal Flag_s       : std_logic;     -- Flag output
   signal Reg_wr       : std_logic;     -- Register bank write signal from cntrl unit
   signal PC_CE_s      : std_logic;     -- PC clock enable signal

begin  -- Processor_A

   ALU_U0 : ALU
      port map (
         In_A   => Reg_out1,
         In_B   => Reg_out2,
         Op_sel => Op_code,
         Flag   => Flag_s,
         Dout   => Alu_out);

   Reg_Bank_U1 : Reg_bank
      port map (
         Din     => Reg_Din,
         Xin     => Xin,
         clk     => clk,
         reset_a => rst,
         Wr_en   => Reg_Wr,
         CE      => dst_sel,
         sel     => src_sel,
         Dout1   => Reg_out1,
         Dout2   => Reg_out2,
         Xout    => Xout,
         Mem_add => Mem_add_s);

   Cntr_unit_U2 : cntrl_unit
      port map (
         Ins        => Ins,
         Z_flag_in  => Z_flag,
         dst_sel    => dst_sel,
         sr_sel     => src_sel,
         reg_wr     => Reg_Wr,
         flag_cntrl => Flag_CE,
         Alu_sel    => Op_code,
         jmp_cntrl  => jmp_cntrl_s,
         off_cntrl  => off_cntrl_s,
         load_cntrl => load_cntrl_s,
         str_cntrl  => str_cntrl_s,
         Imm_cntrl  => Imm_cntrl_s,
         mem_rd     => Rd,
         mem_wr     => Wr,
         PC_CE      => PC_CE_s);


   PC_unit_U3 : PC_Counter
      port map (
         clk       => clk,
         reset_a   => rst,
         Jmp_cntrl => Jmp_cntrl_s,
         PC_CE     => PC_CE_s,
         Off_cntrl => Off_cntrl_s,
         off_set   => Imm_data,
         Mem_Add   => Mem_Add_s,
         PC_out    => PC);
   
-- process for Zero flag generation
   Main_Pro_P : process (clk, rst)
   begin
      if rst = '1' then
         Z_flag    <= '0';
      elsif rising_edge(clk) then
         if Flag_CE = '1' then
            Z_flag <= Flag_s;
         end if;
      end if;

   end process Main_pro_P;
   
   Imm_data <= Ins(7 downto 0);

   -- MUX structure for load instruction**
   Data_2  <= data     when load_cntrl_s = '1' else Data_1;  -- load instruction MUX from memory
   Reg_Din <= Imm_data when Imm_cntrl_s = '1'  else Data_2;  -- MUX for Immediate and data coming
                                        -- from ALU or memory

   -- store instruction DEMUX*
   Data_1 <= Alu_out when str_cntrl_s = '0' else (others => '0');
   Data   <= Alu_out when str_cntrl_s = '1' else (others => 'Z');
   addr   <= Mem_add_s;
end Processor_A;

configuration Processor_C of Processor is

  for Processor_A
  end for;

end Processor_C;
