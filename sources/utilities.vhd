----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/23/2026 07:13:19 PM
-- Design Name: 
-- Module Name: utilities - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package utilities is
    function slv_slice (num_of_elements : natural; orig_element_width : natural; v : std_logic_vector; index : natural; result_width : positive) return std_logic_vector;
    function address_hits_window (addr : std_logic_vector; base : std_logic_vector; mask : std_logic_vector) return boolean;
    function target_slave(num_of_slaves : natural; address_width : natural; slave_base_addr : std_logic_vector; slave_addr_mask : std_logic_vector; addr : std_logic_vector) return natural;
    function is_address_valid(num_of_slaves : natural; address_width : natural; slave_base_addr : std_logic_vector; slave_addr_mask : std_logic_vector; addr : std_logic_vector) return boolean;
end package;

package body utilities is

    function slv_slice (
        num_of_elements : natural;
        orig_element_width : natural;
        v     : std_logic_vector;
        index : natural;
        result_width : positive
    ) return std_logic_vector is
        variable r : std_logic_vector(result_width - 1 downto 0);
        variable l : natural range 0 to num_of_elements * orig_element_width - 1;
    begin
        l := index * result_width;
        r := v(l + result_width - 1 downto l);
        return r;
    end function;

    function address_hits_window(
        addr : std_logic_vector;
        base : std_logic_vector;
        mask : std_logic_vector
    ) return boolean is
    begin
        return (addr and not mask) = (base and not mask);
    end function;

    function target_slave(
        num_of_slaves : natural;
        address_width : natural;
        slave_base_addr : std_logic_vector;
        slave_addr_mask : std_logic_vector;
        addr : std_logic_vector
    ) return natural is
        variable base : std_logic_vector(address_width - 1 downto 0);
        variable mask : std_logic_vector(address_width - 1 downto 0);
    begin
        for s in 0 to num_of_slaves - 1 loop
            base := slv_slice(num_of_slaves, address_width, slave_base_addr, s, address_width);
            mask := slv_slice(num_of_slaves, address_width, slave_addr_mask, s, address_width);
            if address_hits_window(addr, base, mask) then
                return s;
            end if;
        end loop;

        return 0;
    end function;

    function is_address_valid(
        num_of_slaves : natural;
        address_width : natural;
        slave_base_addr : std_logic_vector;
        slave_addr_mask : std_logic_vector;
        addr : std_logic_vector
    ) return boolean is
        variable base : std_logic_vector(address_width - 1 downto 0);
        variable mask : std_logic_vector(address_width - 1 downto 0);
    begin
        for s in 0 to num_of_slaves - 1 loop
            base := slv_slice(num_of_slaves, address_width, slave_base_addr, s, address_width);
            mask := slv_slice(num_of_slaves, address_width, slave_addr_mask, s, address_width);
            if address_hits_window(addr, base, mask) then
                return TRUE;
            end if;
        end loop;

        return FALSE;
    end function;

end utilities;
