#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
// ID location 1 -> 30
// vip 125 ->250
// ID User 1000 -> 8999
// Seller 1150 -> 2049
// ID Product 10000 -> 33999
// ID supply 100000 ->
// ID transaction 1000000 -> 

void generateLocation(FILE *pf) {
    int id = 0;
    char *city[3] = {"HaNoi", "DaNang", "HCM"};
    char *district[10] = {"Quan1", "Quan2", "Quan3", "Quan4", "Quan5", "Quan6", "Quan7", "Quan8", "Quan9", "Quan10"};
    for (int k = 0; k < 3; k++) {
        for (int i = 0; i < 10; i++) {
            id = i + 1 + k * 10;
            fprintf(pf, "INSERT INTO locations VALUES (%d, '%s', '%s');\n",
            id, city[k], district[i]);
        }
    }
}

void generateProduct(FILE *pf) {
    int id = 0;
    char *type[6] = {"Phone", "Laptop", "PC", "Headphone", "Clothes", "Glass"};
    char *manu[6] = {"Apple", "Samsung", "Oppo", "Lenovo", "Gucchi", "Dolce"};
    char *year[12] = {"2010-01-09", "2011-01-09", "2012-01-09", "2013-01-09", 
    "2014-01-09", "2015-01-09", "2016-06-09", "2017-01-09", "2018-01-09", "2019-01-09", "2020-01-09", "2009-01-09"};
    char name[20];
    for (int k = 0; k < 6; k++) {
        for (int i = 0; i < 1000; ++i) {
            id = i + 10000 + k * 4000;
            if (k == 0) sprintf(name, "Iphone%d", i);
            else if (k == 1) sprintf(name, "Samsung%d", i);
            else if (k == 2) sprintf(name, "Oppo%d", i);
            else if (k == 3) sprintf(name, "Lenovo%d", i);
            else if (k == 4) sprintf(name, "Gucchi%d", i);
            else if (k == 5) sprintf(name, "Dolce%d", i);
            fprintf(pf, "INSERT INTO products VALUES (%d, '%s', '%s', '%s', '%s');\n",
             id, name, type[k], manu[k], year[(i + k) % 12]);
        }
        for (int i = 1000; i < 2000; ++i) {
            id = i + 10000 + k * 4000;
            if (k == 0) sprintf(name, "MacBook%d", i - 1000);
            else if (k == 1) sprintf(name, "SungBook%d", i - 1000);
            else if (k == 2) sprintf(name, "OppoHeadp%d", i - 1000);
            else if (k == 3) sprintf(name, "LenovoClo%d", i - 1000);
            else if (k == 4) sprintf(name, "GucchiGlass%d", i - 1000);
            else if (k == 5) sprintf(name, "DolcePhone%d", i - 1000);
            fprintf(pf, "INSERT INTO products VALUES (%d, '%s', '%s', '%s', '%s');\n",
             id, name, type[(k + 1) % 6], manu[k], year[(i + k) % 12]);
        }
         for (int i = 2000; i < 3000; ++i) {
            id = i + 10000 + k * 4000;
            if (k == 0) sprintf(name, "Mac%d", i - 2000);
            else if (k == 1) sprintf(name, "Sam%d", i - 2000);
            else if (k == 2) sprintf(name, "OppoClo%d", i - 2000);
            else if (k == 3) sprintf(name, "LenovoGlass%d", i - 2000);
            else if (k == 4) sprintf(name, "GucchiPhone%d", i - 2000);
            else if (k == 5) sprintf(name, "DolceBook%d", i - 2000);
            fprintf(pf, "INSERT INTO products VALUES (%d, '%s', '%s', '%s', '%s');\n",
             id, name, type[(k + 2) % 6], manu[k], year[(i + k) % 12]);
        }
        for (int i = 3000; i < 4000; ++i) {
            id = i + 10000 + k * 4000;
            if (k == 0) sprintf(name, "Ipod%d", i - 3000);
            else if (k == 1) sprintf(name, "SungClo%d", i - 3000);
            else if (k == 2) sprintf(name, "OppoGlassp%d", i - 3000);
            else if (k == 3) sprintf(name, "LenovoPhone%d", i - 3000);
            else if (k == 4) sprintf(name, "GucchiBook%d", i - 3000);
            else if (k == 5) sprintf(name, "DolcePC%d", i - 3000);
            fprintf(pf, "INSERT INTO products VALUES (%d, '%s', '%s', '%s', '%s');\n",
             id, name, type[(k + 3) % 6], manu[k], year[(i + k) % 12]);
        }
    }
}
int idSupplyArr[1000000];
void generateUser(FILE *pf) {
    int id = 0;
    char *firstName[10] = {"Nguyen", "Luong", "Le", "Do", "Hoang", "Tran", "Van", "Duc", "Viet", "Tuan"};
    char *lastName[10] = {"Duong", "Anh", "Chi", "Hoang", "Long", "Bac", "Nam", "Duc", "An", "Dat"};
    char tel[11];
    char email[40];
    char userName[40];

    for (int i = 0; i < 8000; ++i)
    {
        id = 1000 + i;
        int idxFirstName = i % 10;
        int idxLastName = (i * i) % 10;
        sprintf(tel, "%d%d", id + 1, id + 4);
        sprintf(email, "%s%s%d@email.com", firstName[idxFirstName], lastName[idxLastName], id);
        sprintf(userName, "%s%s%d", firstName[idxFirstName], lastName[idxLastName], id);
        fprintf(pf, "INSERT INTO buyer VALUES (%d, '%s', '%s', '%s', '%s', '%s', 'add_detai', %d);\n", 
            id, firstName[idxFirstName], lastName[idxLastName], tel, email, userName, i % 30 + 1);
    }
}

void generateSeller(FILE *pf) {
    
    for (int i = 1150; i < 2050; ++i)
    {
        fprintf(pf, "INSERT INTO seller VALUES (%d);\n", i);
    }
}

void generateShop(FILE *pf) {
    int isVip = 0;
    char name[20];
    int idSeller = 0;
    int idLocation = 0;
    char *date[12] = {"2010-01-09", "2011-01-09", "2012-01-09", "2013-01-09", 
    "2014-01-09", "2015-01-09", "2016-06-09", "2017-01-09", "2018-01-09", "2019-01-09", "2020-01-09", "2009-01-09"};

    for (int i = 1150; i < 2050; i++) {
        sprintf(name, "Shop%d", i + 1);
        do {
            idLocation = rand() % 30;
        } while (idLocation == 0);
        if (1225 <= i && i <= 1450) isVip = 1;
        else isVip = 0;
        fprintf(pf, "INSERT INTO shops VALUES (%d, '%s', %d, %d, '%s');\n", 
            i, name, isVip, idLocation, date[i % 12]);
    }

}
int check[24000][900] = {0};
int q[24000][900] = {0};
void generateSupply(FILE *pf) {
    int idSupply = 100000;
    int k = 0;
    int idShop = 0;
    int idProduct;
    float price;
    int quantity;
    int sold = 0;
    for (int i = 0; i < 24000; i = i + 3) {
        idProduct = 10000 + i;
        int count = 0;
        do {
            count = rand() % 20;
        } while (count == 0);
        for (int j = 0; j < count; j++) {
            idSupply = idSupply + 1;
            
            idShop = 1150 + rand() % (900);
            price = (float)1000000 + rand()%(50000000);
            quantity = 1 + rand() % (100 - 1);
            sold = rand() % 100;
            if(check[i][idShop - 1150] != 1 && q[i][idShop - 1150] == 0) {
                fprintf(pf, "INSERT INTO supply VALUES (%d, %d, %d, %f, %d, %d);\n",
                idSupply, idShop, idProduct, price, quantity, sold);
                q[i][idShop - 1150] = quantity;
                check[i][idShop - 1150] = 1;
                idSupplyArr[k] = idSupply;
                k ++;
            }
        }
    }
}

void generateCart(FILE *pf) {
    int idSupply = 100000;
    int idUser = 1000;
    int quantity;
    for (int i = 0; i < 30000; i++) {
        idSupply = idSupplyArr[i];
        idUser = 1000 + rand() % 8000;
        fprintf(pf, "INSERT INTO cart VALUES (%d, %d, %d);\n",
            idUser, idSupply, quantity);
    }
}

void generateTransaction(FILE *pf)
{
    int idShop, idCustomer;
    int quantity;

    srand(time(0));
    for (int i = 0; i < 2400; i = i + 1)
    {
        idShop = rand() % 900 + 1150;
        idCustomer = rand() % 8000 + 1000;

        // VALUES (idShop, idCustomer, idTransaction, idProduct, Price, 'year-month-day')
        if (idCustomer != idShop)
        {
            fprintf(pf, "INSERT INTO Transactions VALUES  (%d, %d, %d, %d, %d, %f, '%d-%d-%d');\n",
                    i + 1000000,
                    idCustomer, idShop,
                    rand() % 24000 + 10000, 
                    rand() % 10, 
                    (float)(1000000 + rand()%(50000000)),
                    rand() % 20 + 2000, rand() % 12 + 1, rand() % 27 + 1
                        );
        }
    }
}

void generateVIP(FILE *pf) {
    int idShop = 0;
    char *date[12] = {"2020-12-09", "2020-12-10", "2020-12-11", "2020-12-12", 
    "2020-12-13", "2020-12-14", "2020-11-09", "2020-11-10", "2020-10-09", "2020-10-11", "2020-10-08", "2009-10-15"};
    char *exp[4] = {"3 month", "6 month", "9 month", "1 year"};
    for (int i = 1225; i <= 1450; i++) {
        fprintf(pf, "INSERT INTO vip VALUES (%d, '%s', interval '%s');\n", i, date[i % 12], exp[(i) % 4]);
    }
}

int main()
{
    FILE *pf = fopen("generateData.txt", "w");
    if (pf == NULL) printf("Cannot open file\n");

    fprintf(pf, "\n-- Location\n");
    generateLocation(pf);
    fprintf(pf, "\n-- Product\n");
    generateProduct(pf);
    fprintf(pf, "\n-- User\n");
    generateUser(pf);
    fprintf(pf, "\n-- Seller\n");
    generateSeller(pf);
    fprintf(pf, "\n-- Shop\n");
    generateShop(pf);
    fprintf(pf, "\n-- Supply\n");
    generateSupply(pf);
    fprintf(pf, "\n-- Cart\n");
    generateCart(pf);
    fprintf(pf, "\n-- Vip\n");
    generateVIP(pf);
    fprintf(pf, "\n-- Transaction\n");
    generateTransaction(pf);
    fclose(pf);
    return 0;
}
