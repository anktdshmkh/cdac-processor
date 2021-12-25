-------------------------------------------------------------------------------
-- Title      : Package for Assembler
-- Project    : Processor
-------------------------------------------------------------------------------
-- File       : package.vhd
-- Author     : Aniket Deshmukh  <anktdshmkh@gmail.com>
-- Company    : 
-- Last update: 2006/06/19
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: In this package function F_con is define which used to convert
-- op code which is written in assembly language into machine level language.
-- String of 9 bits is pass to this function and it returns 11 bit op_code i.e.
-- machine code. For immediate instructions like mvi, jmpi or jz it returns 8
-- bit data which is specified in hex format next to these instructions as
-- immediate data. hex_ret function returns hex value of a byte passed to it.
-- This fuction is used in printing the hex value of content of internal
-- register used.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/06/09  1.0      v1      Created
-------------------------------------------------------------------------------

library ieee, std;
use ieee.std_logic_1164.all;
use std.textio.all;

-------------------------------------------------------------------------------
package cpu_pack is

  function f_con (                      -- Function to convert command into
    in_code : string(1 to 9))           -- machine code.
    return std_logic_vector;

  function hex_ret (
    in_byte : std_logic_vector(3 downto 0))
    return character;

end cpu_pack;
-------------------------------------------------------------------------------
package body cpu_pack is

-------------------------------------------------------------------------------
-- hex_conv function for converting hex number into binary number
-- it accepts one character and return it's 4 bit binary value
-------------------------------------------------------------------------------

  function hex_conv (in_reg : character)
    return std_logic_vector is
    variable temp_bin       : std_logic_vector(3 downto 0);
    variable temp_string    : character;
  begin
    temp_string               := in_reg;
    case temp_string is
      when '0'    => temp_bin := "0000";
      when '1'    => temp_bin := "0001";
      when '2'    => temp_bin := "0010";
      when '3'    => temp_bin := "0011";
      when '4'    => temp_bin := "0100";
      when '5'    => temp_bin := "0101";
      when '6'    => temp_bin := "0110";
      when '7'    => temp_bin := "0111";
      when '8'    => temp_bin := "1000";
      when '9'    => temp_bin := "1001";
      when 'a'    => temp_bin := "1010";
      when 'b'    => temp_bin := "1011";
      when 'c'    => temp_bin := "1100";
      when 'd'    => temp_bin := "1101";
      when 'e'    => temp_bin := "1110";
      when 'f'    => temp_bin := "1111";
      when others => null;
    end case;
    return temp_bin;
  end hex_conv;
-------------------------------------------------------------------------------
-- ds_fun is function used to return source and destination addrss
-------------------------------------------------------------------------------
  function ds_fun (
    ins                     : character)
    return std_logic_vector is
    variable reg            : std_logic_vector(2 downto 0);  -- mcode for register
  begin  -- ds_conv
    case ins is
      when 'a'    => reg      := "001";
      when 'b'    => reg      := "010";
      when 'c'    => reg      := "011";
      when 'd'    => reg      := "100";
      when 'x'    => reg      := "101";
      when others => null;              --report "invalid register" severity note;

    end case;
    return reg;

  end ds_fun;

  function f_con (
    in_code : string (1 to 9))          -- Seven char. long command.
    return std_logic_vector is          -- Eleven bit machine code.

    variable mcode : std_logic_vector(10 downto 0);  -- Machine Code for commands.
    variable rline : line;
    variable abc   : std_logic_vector(2 downto 0);
  begin  -- f_con
-------------------------------------------------------------------------------
-- Decoding 5-MSB or 3-MSB of M-code based on first 5 chars of command.
-------------------------------------------------------------------------------      
    case in_code(1 to 5) is
      when "add  "  => mcode(10 downto 6) := "00010";
      when "inc  "  => mcode(10 downto 6) := "00011";
      when "sub  "  => mcode(10 downto 6) := "00100";
      when "dec  "  => mcode(10 downto 6) := "00101";
      when "cmp  "  => mcode(10 downto 6) := "00110";
      when "sl   "  => mcode(10 downto 6) := "01000";
      when "sr   "  => mcode(10 downto 6) := "01001";
      when "mov  "  => mcode(10 downto 6) := "01100";
      when "jmp  "  => mcode(10 downto 6) := "01101";
      when "load "  => mcode(10 downto 6) := "01110";
      when "store"  => mcode(10 downto 6) := "01111";
      when "jmpi "  => mcode(10 downto 8) := "100";
      when "jz   "  => mcode(10 downto 8) := "101";
      when "mvi  "  => mcode(10 downto 8) := "110";
      when "hlt  "  => mcode(10 downto 8) := "111";
      when others   => null;             --report "invalid opcode" severity note;
    end case;
-------------------------------------------------------------------------------
-- Decoding remaining bits of M-Code according to destination and source
-- registers for some instructions and for others it's immediate data
-------------------------------------------------------------------------------

    case in_code(1 to 5) is
      when "mov  "  => mcode(5 downto 3)  := ds_fun(in_code(7));  -- dstination
                       mcode(2 downto 0)  := ds_fun(in_code(9));  -- source
      when "inc  "  => mcode(5 downto 3)  := ds_fun(in_code(7));  -- dstination
                       mcode(2 downto 0)  := ds_fun(in_code(9));  -- source
      when "dec  "  => mcode(5 downto 3)  := ds_fun(in_code(7));  -- destination
                       mcode(2 downto 0)  := ds_fun(in_code(9));  -- source
      when "add  "  => mcode(5 downto 3)  := ds_fun(in_code(7));  -- destination
                       mcode(2 downto 0)  := ds_fun(in_code(9));  -- source
      when "sub  "  => mcode(5 downto 3)  := ds_fun(in_code(7));  -- destiantion
                       mcode(2 downto 0)  := ds_fun(in_code(9));  -- source
      when "sl   "  => mcode(5 downto 3)  := ds_fun(in_code(7));  -- destination
                       mcode(2 downto 0)  := ds_fun(in_code(9));  -- source
      when "sr   "  => mcode(5 downto 3)  := ds_fun(in_code(7));  -- destination
                       mcode(2 downto 0)  := ds_fun(in_code(9));  -- source
      when "load "  => mcode(5 downto 3)  := ds_fun(in_code(7));  -- destination
                       mcode(2 downto 0)  := "000";  -- for load there is no source 
      when "cmp  "  => mcode(5 downto 3)  := "000";  -- for compare no destination
                       mcode(2 downto 0)  := ds_fun(in_code(7));  -- source
      when "store"  => mcode(5 downto 3)  := "000";  -- for store there is no destination
                       mcode(2 downto 0)  := ds_fun(in_code(7));  -- source
-- ALL immediate instruction starts from here
      when "jmpi "  => mcode(7 downto 4)  := hex_conv(in_code(7));
                       mcode(3 downto 0)  := hex_conv(in_code(8));
      when "jz   "  => mcode(7 downto 4)  := hex_conv(in_code(7));
                       mcode(3 downto 0)  := hex_conv(in_code(8));
      when "jmp  "  => mcode(5 downto 0)  := (others => '0');
      when "hlt  "  => mcode(7 downto 0)  := (others => '0');
      when "mvi  "  => mcode(7 downto 4)  := hex_conv(in_code(7));
                       mcode(3 downto 0)  := hex_conv(in_code(8));

      when others => null;              --report "invalid opcode" severity note;
    end case;



    return mcode;


  end f_con;
-- Hex conversion function to convert byte into hex number
  function hex_ret (
    in_byte : std_logic_vector (3 downto 0)) 
     return character is
    variable hex : character;
   begin  -- hex_ret
     case in_byte is
       when "0000" => hex := '0' ;
       when "0001" => hex := '1' ;
       when "0010" => hex := '2' ;
       when "0011" => hex := '3' ;
       when "0100" => hex := '4' ;
       when "0101" => hex := '5' ;
       when "0110" => hex := '6' ;
       when "0111" => hex := '7' ;
       when "1000" => hex := '8' ;
       when "1001" => hex := '9' ;
       when "1010" => hex := 'A' ;
       when "1011" => hex := 'B' ;
       when "1100" => hex := 'C' ;
       when "1101" => hex := 'D' ;
       when "1110" => hex := 'E' ;
       when "1111" => hex := 'F' ;
       when others => null;
     end case;
     return hex;
   end hex_ret;
  
end cpu_pack;
