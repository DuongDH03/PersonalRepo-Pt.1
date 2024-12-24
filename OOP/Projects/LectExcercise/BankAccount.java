package LectExcercise;

public class BankAccount {
    String owner;
    String accountNumber;
    double balance;
    
    boolean credit (double amount){
        if (this.balance >= amount){
            this.balance -= amount;
            return true;
        }
        else return false;
    }

    void debit (double amount){
        if (this.balance >= amount){
            this.balance -= amount;
            System.out.println("Complete");
        }
        else 
            System.out.println("Incomplete");
    }
}
