const API_KEY = '47d32cb10889cbde94e5f5f28ab461e52890034b';
const AUTHORIZATION_KEY = 'Basic YWRtaW46MTIzNA==';
const signature = '9029c9b70f13ba8329bdc57df3e1cd8ad94fcdc0';
const CLINET_ID = "VT-client-Rstbf0xkIEkYi9P_";
const MIDTRANS_CLIENT_KEY = "VT-client-Rstbf0xkIEkYi9P_";
const MIDTRANS_SERVER_KEY = "VT-server-ITqwlFiu66yWI-tvIr-Td7bS";

const ALFAMART_HOWTO_LINE1_ID = "1. Catat kode pembayaran di atas dan datang ke gerai Alfamart, Alfa Midi, Alfa Express, Lawson atau DAN+DAN terdekat.\n\n2. Beritahukan ke kasir bahwa anda ingin melakukan pembayaran DOKU.\n\n3. Jika kasir tidak mengetahui mengenai pembayaran DOKU, informasikan ke kasir untuk membuka terminal e-transaction, pilih \"2\", lalu \"2\", lalu \"2\" yang akan menampilkan pilihan DOKU.\n\n4. Kasir akan menanyakan kode pembayaran. Berikan kode pembayaran anda ";
const ALFAMART_HOWTO_LINE2_ID = ", Kasir akan menginformasikan nominal yang harus dibayarkan.\n\n5. Lakukan pembayaran ke kasir sejumlah nominal yang disebutkan. Pembayaran dapat menggunakan uang tunai atau non tunai. Non tunai antara lain Kartu Debit BCA, Kartu Debit BNI, BCA Flazz, BNI Prepaid dan Mandiri e-money.\n\n6. Terima struk sebagai bukti pembayaran sudah sukses dilakukan. Notifikasi pembayaran akan langsung diterima oleh Merchant.\n\n7. Selesai.";
const HEADER_ID = "Cara membayar di gerai ALFA Group";

const ALFAMART_HOWTO_LINE1_EN = "1. Take note of your payment code and go to your nearest Alfamart, Alfa Midi, Alfa Express, Lawson or DAN+DAN store.\n\n2. Tell the cashier that you wish to make a DOKU payment.\n\n3. If the cashier is unaware of DOKU, provide the instruction to open the e-transaction terminal, choose \"2\", then \"2\", then \"2\" which will then display DOKU option.\n\n4. The cashier will request for the payment code which you will provide ";
const ALFAMART_HOWTO_LINE2_EN = "\n\n5. Make a payment to the cashier according to your transaction amount.\n\n6. Get your receipt as a proof of payment. Your merchant will be directly notified of the payment status.\n\n7. Done.";
const HEADER_EN = "How to pay at ALFA Group";

const GOPAY_HOWTO_LINE1_ID = "- Dengan memilih metode pembayaran ini, pastikan Anda memiliki akun GO-PAY.\n- Metode pembayaran ini tidak memerlukan konfirmasi pembayaran.\n- Metode pembayaran ini mengenakan biaya tambahan\n- Pembayaran GO-PAY diselesaikan via aplikasi GO-JEK.\n- Jika pembayaran dilakukan melalui aplikasi/mobile web, pastikan aplikasi GO-JEK terinstal di ponsel yang sama. Anda akan diarahkan ke aplikasi GO-JEK untuk menyelesaikan pembayaran.\n- Jika pembayaran dilakukan melalui web (desktop), arahkan aplikasi GO-JEK ke QR Code pada halaman pembayaran.";
const GOPAY_HEADER_ID = "Cara membayar menggunakan GO-PAY";

const GOPAY_HOWTO_LINE1_EN = "- Make sure you have a GO-PAY account.\n- Payment confirmation is not necessary.\n- There will be additional fee for GO-PAY Payment method\n- Please complete GO-PAY payment via GO-JEK application\n- If the payment made on an application or a mobile website, you will be redirected to GO-JEK application to complete the payment.\n- If the payment made on a desktop or website, open and point your GO-JEK application to the QR Code on the website screen";
const GOPAY_HEADER_EN = "How to pay using GO-PAY";

class BaseApi{
  final apiUrl = "https://home.eventeventapp.com/api";
  final restUrl = "https://home.eventeventapp.com/rest";
  static final midtransUrlProd = "https://api.midtrans.com";

//   final apiUrl = "http://staging.eventeventapp.com/api";
//   final restUrl = "http://staging.eventeventapp.com/rest";
}