public class MethodOvrLoad {
    public static void main(String [] args){

    }

    public class tester {
        public double test(String a, double b){};
        public String test (String a, double b, int c){};
        public void test (double b, String a);
        public double test (String a);
        private int test (String b, double a);
        private void test (String a, float b);
        private int test (char[] a, double b);
    }
}