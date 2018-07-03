library verilog;
use verilog.vl_types.all;
entity Snooping is
    port(
        SW              : in     vl_logic_vector(17 downto 0);
        LEDR            : out    vl_logic_vector(17 downto 0);
        LEDG            : out    vl_logic_vector(7 downto 0)
    );
end Snooping;
