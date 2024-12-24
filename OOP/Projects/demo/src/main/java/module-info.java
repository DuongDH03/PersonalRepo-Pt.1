module test {
    requires javafx.controls;
    requires javafx.fxml;

    opens test to javafx.fxml;
    exports test;
}
