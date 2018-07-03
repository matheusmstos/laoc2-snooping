library verilog;
use verilog.vl_types.all;
entity maq_receptora is
    generic(
        exclusive       : vl_logic_vector(0 to 1) := (Hi1, Hi0);
        \shared\        : vl_logic_vector(0 to 1) := (Hi0, Hi1);
        invalid         : vl_logic_vector(0 to 1) := (Hi0, Hi0);
        read            : vl_logic := Hi0;
        write           : vl_logic := Hi1;
        read_miss       : vl_logic_vector(0 to 1) := (Hi1, Hi1);
        write_miss      : vl_logic_vector(0 to 1) := (Hi0, Hi1);
        invalidate      : vl_logic_vector(0 to 1) := (Hi1, Hi0);
        hit             : vl_logic := Hi1;
        miss            : vl_logic := Hi0
    );
    port(
        bit_escolha     : in     vl_logic;
        receptor_bus    : in     vl_logic_vector(1 downto 0);
        estado          : in     vl_logic_vector(1 downto 0);
        estado_prox_receptor: out    vl_logic_vector(1 downto 0);
        estado_wb_receptor: out    vl_logic;
        aborta_acesso_mem: out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of exclusive : constant is 1;
    attribute mti_svvh_generic_type of \shared\ : constant is 1;
    attribute mti_svvh_generic_type of invalid : constant is 1;
    attribute mti_svvh_generic_type of read : constant is 1;
    attribute mti_svvh_generic_type of write : constant is 1;
    attribute mti_svvh_generic_type of read_miss : constant is 1;
    attribute mti_svvh_generic_type of write_miss : constant is 1;
    attribute mti_svvh_generic_type of invalidate : constant is 1;
    attribute mti_svvh_generic_type of hit : constant is 1;
    attribute mti_svvh_generic_type of miss : constant is 1;
end maq_receptora;
