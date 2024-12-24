public class MyVal {
    public int value;
    public MyVal(int value) {
        this.value = value;
    }    

    public boolean equals(Object obj) {
        if (obj instanceof MyVal) {
            MyVal that = (MyVal) obj;
            return (this.value) == that.value;
        }
    }
    public static void main (String args []) {
        MyVal v2 = new MyVal(9);
        MyVal v1 = new MyVal(9);
        MyVal v3 = new MyVal(9);
        System.out.println(v1.equals(v3)); //false
        System.out.println(v1.equals(v2)); //true
    }
}
