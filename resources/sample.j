// Phase 1 manual verification sample.
// Open this file in the Experimental Instance and confirm highlighting.

//! import "TimerUtils.j"

library Test requires TimerUtils

    struct MyStruct

        integer value

        method setValue takes integer v returns nothing
            set .value = v
        endmethod

    endstruct

    scope Inner initializer Init

        private function Init takes nothing returns nothing
            local integer i = 0
            local unit u

            set i = i + 1
            set u = CreateUnit(Player(0), 'hfoo', 0.0, 0.0, 0.0)

            if i == 1 then
                call BJDebugMsg("Hello Warcraft III")
            elseif i == 2 then
                call BJDebugMsg("Two")
            else
                call BJDebugMsg("Other")
            endif

            loop
                exitwhen i > 10
                set i = i + 1
            endloop

            /* block comment
               spanning lines */
            return
        endfunction

    endscope

endlibrary
