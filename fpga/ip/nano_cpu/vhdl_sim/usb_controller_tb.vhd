library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.io_bus_pkg.all;
use work.io_bus_bfm_pkg.all;
use work.mem_bus_pkg.all;

--use work.tl_string_util_pkg.all;

entity usb_controller_tb is

end usb_controller_tb;

architecture tb of usb_controller_tb is
    signal clock_50        : std_logic := '0';
    signal clock_60        : std_logic := '0';
    signal reset           : std_logic;
    signal io_req          : t_io_req;
    signal io_resp         : t_io_resp;

    -- ULPI Interface
    signal ULPI_DATA   : std_logic_vector(7 downto 0);
    signal ULPI_DIR    : std_logic;
    signal ULPI_NXT    : std_logic;
    signal ULPI_STP    : std_logic;

	-- LED interface
	signal usb_busy    : std_logic;
	
    -- Memory interface
    signal mem_req     : t_mem_req;
    signal mem_resp    : t_mem_resp := c_mem_resp_init;

begin
    clock_50 <= not clock_50 after 10 ns;
    clock_60 <= not clock_60 after 8.3 ns;
    
    reset <= '1', '0' after 100 ns;
    
    i_io_bfm1: entity work.io_bus_bfm
    generic map (
        g_name      => "io_bfm" )
    port map (
        clock       => clock_50,
    
        req         => io_req,
        resp        => io_resp );

    process
        variable iom  : p_io_bus_bfm_object;
        variable stat : std_logic_vector(7 downto 0);
        variable data : std_logic_vector(7 downto 0);
    begin
        wait for 1 us;
        bind_io_bus_bfm("io_bfm", iom);
        
        io_write(iom, X"1000", X"01"); -- enable core
        
        wait;
    end process;

    i_phy: entity work.ulpi_phy_bfm 
    port map (
        clock       => clock_60,
        reset       => reset,
        
        ULPI_DATA   => ULPI_DATA,
        ULPI_DIR    => ULPI_DIR,
        ULPI_NXT    => ULPI_NXT,
        ULPI_STP    => ULPI_STP );

    i_mut: entity work.usb_controller
    port map (
        ulpi_clock  => clock_60,
        ulpi_reset  => reset,
    
        -- ULPI Interface
        ULPI_DATA   => ULPI_DATA,
        ULPI_DIR    => ULPI_DIR,
        ULPI_NXT    => ULPI_NXT,
        ULPI_STP    => ULPI_STP,
    
    	-- LED interface
    	usb_busy	=> usb_busy,
    	
        -- register interface bus
        sys_clock   => clock_50,
        sys_reset   => reset,
        
        sys_mem_req => mem_req,
        sys_mem_resp=> mem_resp,
    
        sys_io_req  => io_req,
        sys_io_resp => io_resp );
   

end architecture;
 