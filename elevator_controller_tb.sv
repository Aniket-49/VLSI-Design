`timescale 1ns/1ps

module elevator_controller_tb;

    parameter NUM_FLOORS = 8;

    localparam FLOOR_BITS =
        (NUM_FLOORS <= 1) ? 1 : $clog2(NUM_FLOORS);

    // ==================================================
    // SIGNALS
    // ==================================================

    logic clk;
    logic reset;

    logic [NUM_FLOORS-1:0] request;

    logic [FLOOR_BITS-1:0] current_floor;
    logic [FLOOR_BITS-1:0] destination_floor;

    logic motor_up;
    logic motor_down;
    logic door_open;


    // ==================================================
    // DEVICE UNDER TEST
    // ==================================================

    elevator_controller #(
        .NUM_FLOORS(NUM_FLOORS),
        .DOOR_TIME(3)
    ) DUT (

        .clk(clk),
        .reset(reset),

        .request(request),

        .current_floor(current_floor),
        .destination_floor(destination_floor),

        .motor_up(motor_up),
        .motor_down(motor_down),
        .door_open(door_open)
    );


    // ==================================================
    // CLOCK
    // ==================================================

    always #5 clk = ~clk;


    // ==================================================
    // WAVEFORM
    // ==================================================

    initial begin

        $dumpfile("elevator.vcd");
        $dumpvars(0, elevator_controller_tb);

    end


    // ==================================================
    // TEST SEQUENCE
    // ==================================================

    initial begin

        clk     = 0;
        reset   = 1;
        request = 4'b0000;


        // ----------------------------------------------
        // RESET
        // ----------------------------------------------

        #20;

        reset = 0;

// ==============================================
// TEST 1
// Floor 0 -> Floor 7
// ==============================================

$display("TEST 1: Request Floor 7");

request = 8'b10000000;

#10;

request = 8'b00000000;

#150;


// ==============================================
// TEST 2
// Floor 7 -> Floor 2
// ==============================================

$display("TEST 2: Request Floor 2");

request = 8'b00000100;

#10;

request = 8'b00000000;

#150;


// ==============================================
// TEST 3
// Multiple requests
// Floors 1, 4 and 6
// ==============================================

$display("TEST 3: Multiple Requests");

request = 8'b01010010;

#10;

request = 8'b00000000;

#300;


// ==============================================
// TEST 4
// Same-floor request
// ==============================================

$display("TEST 4: Request Floor 1");

request = 8'b00000010;

#10;

request = 8'b00000000;

#150;


// ==============================================
// END
// ==============================================

$display("All 8-floor tests completed.");

$finish;
    end


    // ==================================================
    // MONITOR
    // ==================================================

    initial begin

        $monitor(
            "Time=%0t | Request=%b | Current=%0d | Destination=%0d | UP=%b | DOWN=%b | DOOR=%b",
            $time,
            request,
            current_floor,
            destination_floor,
            motor_up,
            motor_down,
            door_open
        );

    end

endmodule