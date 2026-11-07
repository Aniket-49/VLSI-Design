module elevator_controller #(
    parameter NUM_FLOORS = 4,
    parameter DOOR_TIME  = 3,
    parameter FLOOR_BITS = (NUM_FLOORS <= 1) ? 1 : $clog2(NUM_FLOORS)
)(
    input  wire                  clk,
    input  wire                  reset,

    input  wire [NUM_FLOORS-1:0] request,

    output reg [FLOOR_BITS-1:0] current_floor,
    output reg [FLOOR_BITS-1:0] destination_floor,

    output reg motor_up,
    output reg motor_down,
    output reg door_open
);

    // ==================================================
    // FSM STATE ENCODING
    // ==================================================

    localparam IDLE      = 2'b00;
    localparam MOVE_UP   = 2'b01;
    localparam MOVE_DOWN = 2'b10;
    localparam DOOR_OPEN = 2'b11;

    reg [1:0] state;

    // ==================================================
    // REQUEST STORAGE
    // ==================================================

    reg [NUM_FLOORS-1:0] pending_requests;

    // ==================================================
    // DOOR TIMER
    // ==================================================

    localparam TIMER_BITS =
        (DOOR_TIME <= 1) ? 1 : $clog2(DOOR_TIME + 1);

    reg [TIMER_BITS-1:0] door_counter;

    // ==================================================
    // DESTINATION SELECTION
    // ==================================================

    integer i;

    reg [NUM_FLOORS-1:0] all_requests;
    reg                   found_request;
    reg [FLOOR_BITS-1:0] selected_floor;

    always @(*) begin

        // Combine stored and new requests
        all_requests = pending_requests | request;

        found_request = 1'b0;
        selected_floor = current_floor;

        // ----------------------------------------------
        // Priority 1: Current floor
        // ----------------------------------------------

        if (all_requests[current_floor]) begin

            selected_floor = current_floor;
            found_request = 1'b1;

        end

        // ----------------------------------------------
        // Priority 2: Search floors above
        // ----------------------------------------------

        if (!found_request) begin

            for (i = 1; i < NUM_FLOORS; i = i + 1) begin

                if ((current_floor + i < NUM_FLOORS) &&
                    all_requests[current_floor + i] &&
                    !found_request) begin

                    selected_floor = current_floor + i;
                    found_request = 1'b1;

                end

            end

        end

        // ----------------------------------------------
        // Priority 3: Search floors below
        // ----------------------------------------------

        if (!found_request) begin

            for (i = 1; i < NUM_FLOORS; i = i + 1) begin

                if ((current_floor >= i) &&
                    all_requests[current_floor - i] &&
                    !found_request) begin

                    selected_floor = current_floor - i;
                    found_request = 1'b1;

                end

            end

        end

    end

    // ==================================================
    // MAIN FSM
    // ==================================================

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            current_floor     <= 0;
            destination_floor <= 0;
            pending_requests  <= 0;
            door_counter      <= 0;
            state             <= IDLE;

        end

        else begin

            case (state)

                // ======================================
                // IDLE
                // ======================================

                IDLE: begin

                    door_counter <= 0;

                    pending_requests <=
                        pending_requests | request;

                    if (found_request) begin

                        destination_floor <= selected_floor;

                        if (selected_floor > current_floor)
                            state <= MOVE_UP;

                        else if (selected_floor < current_floor)
                            state <= MOVE_DOWN;

                        else
                            state <= DOOR_OPEN;

                    end

                end

                // ======================================
                // MOVE UP
                // ======================================

                MOVE_UP: begin

                    pending_requests <=
                        pending_requests | request;

                    if (current_floor < destination_floor) begin

                        current_floor <= current_floor + 1'b1;

                    end
                    else begin

                        state <= DOOR_OPEN;

                    end

                end

                // ======================================
                // MOVE DOWN
                // ======================================

                MOVE_DOWN: begin

                    pending_requests <=
                        pending_requests | request;

                    if (current_floor > destination_floor) begin

                        current_floor <= current_floor - 1'b1;

                    end
                    else begin

                        state <= DOOR_OPEN;

                    end

                end

                // ======================================
                // DOOR OPEN
                // ======================================

                DOOR_OPEN: begin

                    pending_requests <=
                        (pending_requests | request) &
                        ~(1'b1 << destination_floor);

                    if (door_counter < DOOR_TIME) begin

                        door_counter <= door_counter + 1'b1;

                    end
                    else begin

                        door_counter <= 0;
                        state <= IDLE;

                    end

                end

                // ======================================
                // DEFAULT
                // ======================================

                default: begin

                    state <= IDLE;

                end

            endcase

        end

    end

    // ==================================================
    // OUTPUT LOGIC
    // ==================================================

    always @(*) begin

        motor_up   = 1'b0;
        motor_down = 1'b0;
        door_open  = 1'b0;

        case (state)

            MOVE_UP:
                motor_up = 1'b1;

            MOVE_DOWN:
                motor_down = 1'b1;

            DOOR_OPEN:
                door_open = 1'b1;

            default: begin
                motor_up   = 1'b0;
                motor_down = 1'b0;
                door_open  = 1'b0;
            end

        endcase

    end

endmodule
