*&---------------------------------------------------------------------*
*&   Racing Car Requirements Specification
*&---------------------------------------------------------------------*
*&
*& In this program you'll find the starting code for four distinct problems.
*& They could be code you inherited from a legacy code-base. Now you want
*& to write unit tests for them, and that is harder than it needs to be. All
*& of the code snippets fail to follow one or more of the SOLID principles.
*&
*& For each exercise, you should identify which SOLID principles are not
*& being followed by the code. There is only one class you are interested
*& in writing tests for right now. As a first step, try to get some kind
*& of test in place before you change the class at all. If the tests are
*& hard to write, is that because of the problems with SOLID principles?
*&
*& When you have some kind of test to lean on, refactor the code and make
*& it testable. Take care when refactoring not to alter the functionality,
*& or change interfaces which other client code may rely on. (Imagine there
*& is client code in another repository that you can't see right now). Add
*& more tests to cover the functionality of the particular class you've been
*& asked to get under test.
*&
*& Apply the unit testing style and framework you are most comfortable with.
*& You can choose to use stubs or mocks or none at all. If you do, you are
*& free to use the mocking tool that you prefer.

PROGRAM yy_pao_racing_car.

*&---------------------------------------------------------------------*
*&   1) Tire Pressure Monitoring System exercise
*&---------------------------------------------------------------------*
*&
*&  Write the unit tests for the Alarm class. The Alarm class is designed to
*&  monitor tire pressure and set an alarm if the pressure falls outside of
*&  the expected range. The Sensor class provided for the exercise fakes the
*&  behavior of a real tire sensor, providing random but realistic values.

*& Production Code - Tire Pressure Monitoring System
CLASS lcl_sensor DEFINITION FINAL.
  " The reading of the pressure value from the sensor is simulated in this
  " implementation. Because the focus of the exercise is on the other class.
  PUBLIC SECTION.
    METHODS:
      pop_next_pressure_psi_value
        RETURNING VALUE(rv_value) TYPE f.
  PRIVATE SECTION.
    CONSTANTS:
      offset TYPE f VALUE 16.
    CLASS-METHODS:
      read_sample_pressure
        RETURNING VALUE(rv_value) TYPE f.
ENDCLASS.

CLASS lcl_sensor IMPLEMENTATION.
  METHOD pop_next_pressure_psi_value.
    DATA(lv_pressure_telemetry) = read_sample_pressure( ).
    rv_value = offset + lv_pressure_telemetry.
  ENDMETHOD.
  METHOD read_sample_pressure.
    " placeholder implementation that simulates a real sensor in a real tire
    DATA(lo_rng) = cl_abap_random_float=>create( ).
    rv_value = CONV f( 6 ) * lo_rng->get_next( ) * lo_rng->get_next( ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_alarm DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
      constructor,
      check,
      is_alarm_on
        RETURNING VALUE(rv_result) TYPE abap_bool.
    DATA:
      mo_sensor   TYPE REF TO lcl_sensor,
      mv_alarm_on TYPE abap_bool.
  PRIVATE SECTION.
    CONSTANTS:
      low_pressure_threshold TYPE i VALUE 17,
      high_pressure_threshold TYPE i VALUE 21.
ENDCLASS.

CLASS lcl_alarm IMPLEMENTATION.
  METHOD constructor.
    mo_sensor   = NEW #( ).
    mv_alarm_on = abap_false.
  ENDMETHOD.
  METHOD check.
    DATA(lv_psi_pressure) = mo_sensor->pop_next_pressure_psi_value( ).
    IF lv_psi_pressure < low_pressure_threshold OR
       high_pressure_threshold < lv_psi_pressure.
      mv_alarm_on = abap_true.
    ENDIF.
  ENDMETHOD.
  METHOD is_alarm_on.
    rv_result = mv_alarm_on.
  ENDMETHOD.
ENDCLASS.


*& Test Code - Tire Pressure Monitoring System exercise
CLASS ltc_test_alarm DEFINITION FOR TESTING RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS:
      alarm_off_by_default FOR TESTING.
ENDCLASS.

CLASS ltc_test_alarm IMPLEMENTATION.
  METHOD alarm_off_by_default.
    cl_abap_unit_assert=>assert_false( NEW lcl_alarm( )->is_alarm_on( ) ).
  ENDMETHOD.
ENDCLASS.


*&---------------------------------------------------------------------*
*&   2) Unicode File to Html Text Converter exercise
*&---------------------------------------------------------------------*
*&
*&  Write the unit tests for the Unicode File to Html Text Converter.
*&  The Html Text Converter class is designed to reformat a plain text
*&  file for display in a browser.

*& Production Code - Text Converter
CLASS lcl_html_text_converter DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING iv_full_filename_with_path TYPE string,
      convert_to_html
        RETURNING VALUE(rv_html) TYPE string
        RAISING cx_sy_file_access_error,
      filename
        RETURNING VALUE(rv_filename) TYPE string.
  PRIVATE SECTION.
    DATA:
      mv_full_filename_with_path TYPE string.
ENDCLASS.

CLASS lcl_html_text_converter IMPLEMENTATION.
  METHOD constructor.
    mv_full_filename_with_path = iv_full_filename_with_path.
  ENDMETHOD.
  METHOD convert_to_html.
    OPEN DATASET mv_full_filename_with_path FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    DATA(lv_line) = VALUE string( ).
    DO.
      READ DATASET mv_full_filename_with_path INTO lv_line.
      IF sy-subrc = 0.
        rv_html = rv_html && lv_line.
        rv_html = rv_html && |<br />|.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
    CLOSE DATASET mv_full_filename_with_path.
  ENDMETHOD.
  METHOD filename.
    rv_filename = mv_full_filename_with_path.
  ENDMETHOD.
ENDCLASS.


*& Test Code - Unicode File To Html Text Converter exercise
CLASS ltc_html_text_converter DEFINITION FOR TESTING RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS:
      do_something FOR TESTING.
ENDCLASS.

CLASS ltc_html_text_converter IMPLEMENTATION.
  METHOD do_something.
    DATA(lo_conveter) = NEW lcl_html_text_converter( |./any.txt| ).
  ENDMETHOD.
ENDCLASS.


*&---------------------------------------------------------------------*
*&   3) Ticket Dispenser exercise
*&---------------------------------------------------------------------*
*&
*&  Write the unit tests for the Ticket Dispenser. The Ticket Dispenser class
*&  is designed to be used to manage a queuing system in a shop. There may
*&  be more than one ticket dispenser but the same turn number ticket should
*&  not be issued to two different customers.

*& Production Code - Ticket Dispenser
CLASS lcl_turn_ticket DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING iv_turn_number TYPE i,
      turn_number
        RETURNING VALUE(rv_number) TYPE i.
  PRIVATE SECTION.
    DATA:
      mv_turn_number TYPE i.
ENDCLASS.

CLASS lcl_turn_number_sequence DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      next_turn_number
        RETURNING VALUE(rv_number) TYPE i.
  PRIVATE SECTION.
    CLASS-DATA:
      gv_turn_number TYPE i VALUE 0.
ENDCLASS.

CLASS lcl_ticket_dispenser DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
      next_turn_ticket
        RETURNING VALUE(ro_ticket) TYPE REF TO lcl_turn_ticket.
ENDCLASS.

CLASS lcl_turn_ticket IMPLEMENTATION.
  METHOD constructor.
    mv_turn_number = iv_turn_number.
  ENDMETHOD.
  METHOD turn_number.
    rv_number = mv_turn_number.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_turn_number_sequence IMPLEMENTATION.
  METHOD next_turn_number.
    gv_turn_number = gv_turn_number + 1.
    rv_number = gv_turn_number.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_ticket_dispenser IMPLEMENTATION.
  METHOD next_turn_ticket.
    DATA(lv_new_turn_number) = lcl_turn_number_sequence=>next_turn_number( ).
    DATA(lo_new_turn_ticket) = NEW lcl_turn_ticket( lv_new_turn_number ).
    ro_ticket = lo_new_turn_ticket.
  ENDMETHOD.
ENDCLASS.


*& Test Code - Ticket Dispenser exercise
CLASS ltc_test_ticket_dispenser DEFINITION FOR TESTING RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS:
      do_something FOR TESTING.
ENDCLASS.

CLASS ltc_test_ticket_dispenser IMPLEMENTATION.
  METHOD do_something.
    DATA(lo_dispenser) = NEW lcl_ticket_dispenser( ).
    DATA(lo_ticket) = lo_dispenser->next_turn_ticket( ).
  ENDMETHOD.
ENDCLASS.


*&---------------------------------------------------------------------*
*&   4) Telemetry System exercise
*&---------------------------------------------------------------------*
*&
*&  Write the unit tests for the Telemetry Diagnostic (Control) class.
*&  The responsibility of the Telemetry Diagnostic class is to establish
*&  a connection to the telemetry server (through the Telemetry Client),
*&  send a diagnostic request and successfully receive the response that
*&  contains the diagnostic info. The Telemetry Client class provided for
*&  the exercise fakes the behavior of the real Telemetry Client class, and
*&  can respond with either the diagnostic information or a random sequence.
*&  The real Telemetry Client class would connect and communicate with the
*&  actual telemetry server via TCP/IP.

*& Production Code - Telemetry System
CLASS lcx_illegal_argument DEFINITION FINAL INHERITING FROM cx_dynamic_check.
ENDCLASS.

CLASS lcx_unable_to_connect DEFINITION FINAL INHERITING FROM cx_static_check.
ENDCLASS.

CLASS lcl_telemetry_client DEFINITION FINAL.
  " The communication with the server is simulated in this implementation.
  " Because the focus of the exercise is on the other class.
  PUBLIC SECTION.
    CONSTANTS:
      diagnostic_message TYPE string VALUE 'AT#UD'.
    METHODS:
      constructor,
      online_status
        RETURNING VALUE(rv_status) TYPE abap_bool,
      connect
        IMPORTING iv_telementry_connection TYPE string,
      disconnect,
      send
        IMPORTING iv_message TYPE string,
      receive
        RETURNING VALUE(rv_message) TYPE string.
  PRIVATE SECTION.
    DATA:
      mv_online_status   TYPE abap_bool,
      mv_diagnostic_sent TYPE abap_bool,
      mo_event_simulator TYPE REF TO cl_abap_random.
ENDCLASS.

CLASS lcl_telemetry_diagnostic DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
      constructor,
      diagnostic_info
        RETURNING VALUE(rv_info) TYPE string,
      set_diagnostic_info
        IMPORTING iv_diagnostic_info TYPE string,
      check_transmission
        RAISING lcx_unable_to_connect.
  PRIVATE SECTION.
    CONSTANTS:
      diagnostic_channel_connection TYPE string VALUE '*111#'.
    DATA:
      mo_telemetry_client TYPE REF TO lcl_telemetry_client,
      mv_diagnostic_info TYPE string.
ENDCLASS.

CLASS lcl_telemetry_client IMPLEMENTATION.
  METHOD constructor.
    mv_online_status   = abap_false.
    mv_diagnostic_sent = abap_false.
    mo_event_simulator = cl_abap_random=>create( 42 ).
  ENDMETHOD.
  METHOD online_status.
    rv_status = mv_online_status.
  ENDMETHOD.
  METHOD connect.
    IF iv_telementry_connection IS INITIAL.
      RAISE EXCEPTION TYPE lcx_illegal_argument.
    ENDIF.
    " simulate the operation on a real modem with 80% chance of success
    DATA(lv_success) = xsdbool( mo_event_simulator->intinrange( low = 1 high = 10 ) <= 8 ).
    mv_online_status = lv_success.
  ENDMETHOD.
  METHOD disconnect.
    mv_online_status = abap_false.
  ENDMETHOD.
  METHOD send.
    IF iv_message IS INITIAL.
      RAISE EXCEPTION TYPE lcx_illegal_argument.
    ENDIF.
    " The simulation of Send( ) actually just remembers if the last message sent was diagnostic message.
    " This information will be used to simulate the Receive( ) since there is no real server listening.
    mv_diagnostic_sent = xsdbool( iv_message = diagnostic_message ).
    " here should go the real Send operation (not needed for this exercise)
  ENDMETHOD.
  METHOD receive.
    DATA(lv_message_result) = VALUE string( ).
    IF mv_diagnostic_sent = abap_true.
      " simulate the reception of a status report for the diagnostic message
      lv_message_result = |LAST TX rate................ 100 MBPS\r\n| &&
                          |HIGHEST TX rate............. 100 MBPS\r\n"| &&
                          |LAST RX rate................ 100 MBPS\r\n| &&
                          |HIGHEST RX rate............. 100 MBPS\r\n| &&
                          |BIT RATE.................... 100000000\r\n| &&
                          |WORD LEN.................... 16\r\n| &&
                          |WORD/FRAME.................. 511\r\n| &&
                          |BITS/FRAME.................. 8192\r\n| &&
                          |MODULATION TYPE............. PCM/FM\r\n| &&
                          |TX Digital Los.............. 0.75\r\n| &&
                          |RX Digital Los.............. 0.10\r\n| &&
                          |BEP Test.................... -5\r\n| &&
                          |Local Rtrn Count............ 00\r\n| &&
                          |Remote Rtrn Count........... 00|.
    ELSE.
      " simulate the reception of a response returned for a random message
      DATA(lv_message_length) = mo_event_simulator->intinrange( high = 50 ) + 60.
      DO lv_message_length TIMES.
        DATA(lv_random_int) = mo_event_simulator->intinrange( high = 40 ) + 86.
        lv_message_result = lv_message_result && cl_abap_conv_in_ce=>uccpi( lv_random_int ).
      ENDDO.
    ENDIF.
    rv_message = lv_message_result.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_telemetry_diagnostic IMPLEMENTATION.
  METHOD constructor.
    mo_telemetry_client = NEW #( ).
    mv_diagnostic_info  = VALUE #( ).
  ENDMETHOD.
  METHOD diagnostic_info.
    rv_info = mv_diagnostic_info.
  ENDMETHOD.
  METHOD set_diagnostic_info.
    mv_diagnostic_info = iv_diagnostic_info.
  ENDMETHOD.
  METHOD check_transmission.
    CLEAR mv_diagnostic_info.
    mo_telemetry_client->disconnect( ).
    DATA(lv_retry_left) = 3.
    WHILE NOT mo_telemetry_client->online_status( ) AND lv_retry_left > 0.
      mo_telemetry_client->connect( diagnostic_channel_connection ).
      lv_retry_left = lv_retry_left - 1.
    ENDWHILE.
    IF NOT mo_telemetry_client->online_status( ).
      RAISE EXCEPTION TYPE lcx_unable_to_connect.
    ENDIF.
    mo_telemetry_client->send( lcl_telemetry_client=>diagnostic_message ).
    mv_diagnostic_info = mo_telemetry_client->receive( ).
  ENDMETHOD.
ENDCLASS.


*& Test Code - Telemetry System exercise
CLASS ltc_test_telemetry_diagnostic DEFINITION FOR TESTING RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS:
      send_diagnostic_receive_status FOR TESTING
        RAISING lcx_unable_to_connect.
ENDCLASS.

CLASS ltc_test_telemetry_diagnostic IMPLEMENTATION.
  METHOD send_diagnostic_receive_status.
    DATA(lo_ctrl) = NEW lcl_telemetry_diagnostic( ).
    lo_ctrl->check_transmission( ).
    lo_ctrl->diagnostic_info( ).
  ENDMETHOD.
ENDCLASS.


*&---------------------------------------------------------------------*
*&   5) Leader Board exercise (note this exercise is still being developed)
*&---------------------------------------------------------------------*
*&
*&  Write the unit tests for the Leader Board class, including races with self
*&  driving cars. The Leader Board calculates driver points and rankings based
*&  on results from a number of races.

*& Production Code - Leader Board


*& Test Code - Leader Board exercise
