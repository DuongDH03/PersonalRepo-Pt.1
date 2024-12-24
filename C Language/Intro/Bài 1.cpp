/* Bài 1.  Một cửa hàng tiện lợi cần quản lý thông tin sản phẩm và số lượng sản phẩm mà của hàng đang có gồm
•	Mã sản phẩm
•	Tên sản phẩm
•	Loại sản phẩm
•	Số lượng còn
•	Giá cho 1 sản phẩm
Ví dụ
(D01, Coca cola, đồ uống, 1010, 8000)
(D12, Clear chai nhỏ, Dầu gội, 23, 85000)
Hãy xây dựng chương trình để 
1.	nhập vào thông tin các sản phẩm mà cửa hàng đang có. Ngừng nhập khi nhập vào tên sản phẩm là $$$
2.	In ra thông tin các sản phẩm thuộc nhóm nhập từ bàn phím, ví dụ nhóm : đồ uống
3.	Thông tin giỏ hàng của khách hàng gồm: Mã sản phẩm và số lượng
Hãy nhập vào thông tin giỏ hàng và tính tiền cho đơn hàng trên (tiền thanh toán sẽ cộng thêm 8% VAT)
4.	In ra danh sách các sản phẩm có số lượng nhỏ hơn k (nhập từ bàn phím)
Thông tin in ra gồm : Mã sản phẩm, tên sản phẩm, số lượng còn */

#include <stdio.h>
#include <string.h>
struct sanpham{
	char masp[10];
	char tensp[20];
	char loaisp[20];
	int slcon;
	int gia; 
	int slmua;
};
int main(){
	struct sanpham sp[100];
	int j,i=0;
	//Nhap san pham
	while (true){
		printf("Nhap ten san pham (nhap $$$ de ket thuc) :\n");
		gets(sp[i].tensp); 
		if (strcmp(sp[i].tensp, "$$$") == 0) break;
		printf("Nhap ma san pham :\n");
		gets(sp[i].masp); 
		printf("Nhap loai san pham :\n");
		gets(sp[i].loaisp); 
		printf("Nhap so luong san pham :\n");
		scanf("%d",&sp[i].slcon); 
		printf("Nhap gia san pham :\n");
		scanf("%d",&sp[i].gia); fflush(stdin);
		i++;
}	
	//In danh sach san pham
	printf("===========================Danh sach san pham===========================\n");
	printf("%-20s%-20s%-20s%-20s%-20s\n", "Ma san pham", "Ten san pham", "Loai san pham", "So luong con lai", "Gia");
	for (int j = 0; j<i; j++){
		printf("%-20s%-20s%-20s%-20d%-20d\n", sp[j].masp, sp[j].tensp, sp[j].loaisp, sp[j].slcon, sp[j].gia);
	}
	//In thong tin san pham theo nhom
	char nhomsp[20];
	printf("Nhap nhom san pham muon tim\n");
	fflush(stdin);
	gets(nhomsp);
	printf("================================Danh sach san pham================================\n");
	printf("%-20s%-20s%-20s%-20s%-20s\n", "Ma san pham", "Ten san pham", "Loai san pham", "So luong con lai", "Gia");
	int danhdau=0;
	for (j=0; j<i; j++){
		if (strcmp(sp[j].loaisp,nhomsp)==0) {
			danhdau++;
			printf("%-20s%-20s%-20s%-20d%-20d\n", sp[j].masp, sp[j].tensp, sp[j].loaisp, sp[j].slcon, sp[j].gia);
			}
	}
	if (danhdau==0) printf("                                khong co san pham can tim\n");
	//Nhap gio hang tinh tien
	char giohang[20];
	double tientong=0;
	while (true){
		printf("Nhap ma san pham can mua (nhap 'het' de ket thuc)\n");
		fflush(stdin);
		gets(giohang); 
		if (strcmp(giohang,"het")==0) break;
		for (j=0; j<i; j++) {
			if (strcmp(giohang,sp[j].masp)==0) break;
		}
		printf("Nhap so luong san pham \n");
		while (true){
			scanf("%d",&sp[j].slmua); 
			if (sp[j].slmua>sp[j].slcon) printf("Nhap so luong san pham hop le (<%d)\n",sp[j].slcon+1);	
			else break;
		}
	}
	printf("======Gio hang======\n");
	printf("%-20s%-20s%-20s\n", "Ma san pham", "So luong", "Gia");
	for (int j = 0; j<i; j++){
		if (sp[j].slmua>0) {
		printf("%-20s%-20d%-20d\n", sp[j].masp, sp[j].slmua, sp[j].gia);
		tientong= tientong + sp[j].slmua*sp[j].gia;
		}
	}
	tientong=tientong*108/100;
	printf("Tien can thanh toan la %.2fVND (Da bao gom 8%%VAT)\n",tientong);
	//Danh sach san pham < k
	int k;
	printf("Nhap so luong k :\n");
	scanf("%d",&k);
	danhdau=0;
	printf("Danh sach san pham con it hon %d \n",k);
	printf("%-20s%-20s%-20d\n", "Ma san pham", "Ten san pham", "So luong con lai");
	for (j=0; j<i; j++){
		if (sp[j].slcon<k) {
			danhdau++;
			printf("%-20s%-20s%-20d\n", sp[j].masp, sp[j].tensp, sp[j].slcon);
			}
	}
	if (danhdau==0) printf("khong co san pham can tim\n");
	return 0;
}
	

                                
