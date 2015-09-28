import BoardList;
import CabList;
import GetMagByType;
import HostName;
import MagList;
import NEdata;
import RSADecript;
import Room;
import TypeOfSub;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import java.util.StringTokenizer;
import javax.swing.JTextField;

public class GetDataFromMGW {
    static GetMagByType MagL = new GetMagByType();

    public static NEdata getData(HostName host, boolean decriptP) throws InterruptedException {
        NEdata NE = new NEdata();
        boolean login = false;
        byte[] EndP = new byte[]{3, 60};
        byte[] EndL = new byte[]{3, 62};
        Socket Soc = null;
        PrintWriter out = null;
        InputStreamReader is = null;
        byte[] SEND = new byte[]{10, 13};
        MagL.initial();
        if (host.getIPmain().isEmpty() | host.getPort().isEmpty()) {
            return null;
        }
        try {
            Soc = new Socket(host.getIPmain(), Integer.parseInt(host.getPort()));
            out = new PrintWriter(Soc.getOutputStream(), true);
            is = new InputStreamReader(Soc.getInputStream());
            String line = GetDataFromMGW.getLine(is, "username:").toString();
            System.out.println(line);
            if (line.length() > 0) {
                out.print(String.valueOf(host.getUser()) + "\r");
                out.flush();
                Room.textField.setText("Send User");
                System.out.println("Send User");
            }
            line = GetDataFromMGW.getLine(is, "password:").toString();
            System.out.println(line);
            Room.textField.setText("Send Password");
            if (line.length() > 0) {
                if (decriptP) {
                    out.print(String.valueOf(RSADecript.DecriptData(host.getPassword())) + "\r");
                } else {
                    out.print(String.valueOf(host.getPassword()) + "\r");
                }
                out.flush();
                System.out.println("Send Pass");
            }
            if (host.getDomain().length() > 0) {
                line = GetDataFromMGW.getLine(is, "DOMAIN").toString();
                System.out.println(line);
                Room.textField.setText("Send DOMAIN");
                if (line.length() > 0) {
                    out.print(String.valueOf(host.getDomain()) + "\r");
                    out.flush();
                    System.out.println("Send Domain:" + host.getDomain());
                }
                line = GetDataFromMGW.getLine(is, "$").toString();
                System.out.println(line);
                login = true;
                NE.Autoris = "Ok";
            } else {
                out.print("\r");
                out.flush();
                line = GetDataFromMGW.getLine(is, "$").toString();
                System.out.println(line);
                login = true;
                NE.Autoris = "Ok";
            }
            if (line.indexOf("NOT ACCEPTED") > -1) {
                login = false;
                NE.Autoris = "NOT ACCEPTED";
            }
            if (line.indexOf("failure") > -1) {
                login = false;
                NE.Autoris = "Login Failure";
            }
        }
        catch (UnknownHostException e) {
            System.err.println("Fault connect to host:" + host.getIPmain());
        }
        catch (IOException e) {
            System.err.println("IO Error");
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        try {
            if (login) {
                out.print("ncli\r");
                out.flush();
                System.out.println("ncli");
                System.out.println(GetDataFromMGW.getLine(is, new String(EndL)));
                Room.textField.setText("get .");
                out.print("get .\r");
                out.flush();
                System.out.println("get .");
                NE = GetDataFromMGW.loadMGWGlobal(GetDataFromMGW.getLine(is, new String(EndL)));
                NE.Name = host.Name;
                NE.Region = host.Region;
                NE.Filial = host.Filial;
                out.print("search . Subrack\r");
                out.flush();
                List<String> Subrack = GetDataFromMGW.loadSubrackMGW(GetDataFromMGW.getLine(is, new String(EndL)));
                for (int i = 0; i < Subrack.size(); ++i) {
                    out.print("get " + Subrack.get(i) + "\r");
                    out.flush();
                    Room.textField.setText("get " + Subrack.get(i));
                    System.out.println("get " + Subrack.get(i));
                    NE = GetDataFromMGW.loadCurrentSubrack(NE, GetDataFromMGW.getLine(is, new String(EndL)));
                }
                out.print("search . Slot  slotState==1\r");
                out.flush();
                List<String> Boards = GetDataFromMGW.loadSubrackMGW(GetDataFromMGW.getLine(is, new String(EndL)));
                for (int i2 = 0; i2 < Boards.size(); ++i2) {
                    out.print("get " + Boards.get(i2) + "\r");
                    out.flush();
                    Room.textField.setText("get " + Boards.get(i2));
                    System.out.println("get " + Boards.get(i2));
                    NE = GetDataFromMGW.loadCurrentBoards(NE, GetDataFromMGW.getLine(is, new String(EndL)));
                }
                if (NE.APT.indexOf("GMPV3") > -1) {
                    out.print("search . MgwFan\r");
                    out.flush();
                    NE = GetDataFromMGW.loadGMPV3Fan(NE, GetDataFromMGW.getLine(is, new String(EndL)));
                }
                if (NE.APT.indexOf("GMPV4") > -1) {
                    out.print("search . Fan\r");
                    out.flush();
                    NE = GetDataFromMGW.loadGMPV4Fan(NE, GetDataFromMGW.getLine(is, new String(EndL)));
                }
            }
        }
        catch (IOException e1) {
            e1.printStackTrace();
        }
        try {
            out.close();
            is.close();
            Soc.close();
            System.out.println("Thread iner complited");
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        return NE;
    }


    private static StringBuilder getLine(InputStreamReader is, String find) throws IOException, InterruptedException {

        throw new IllegalStateException("");
    }

    private static String get_col(String line, String Delemiter, int numcol) {
        String rez_data = "";
        String col = "";
        int count = 0;
        StringTokenizer st = new StringTokenizer(line, Delemiter, true);
        while (st.hasMoreTokens()) {
            col = st.nextToken().trim();
            if (col.equals("") || col.equals(Delemiter) || ++count != numcol) continue;
            rez_data = col;
            break;
        }
        return rez_data;
    }

    private static List<String> loadSubrackMGW(StringBuilder line) {
        ArrayList<String> CL = new ArrayList<String>();
        String Line = "";
        Scanner scanner = new Scanner(line.toString());
        while (scanner.hasNext()) {
            Line = scanner.nextLine().trim();
            if (Line.indexOf("Subrack=") <= -1) continue;
            CL.add(Line);
        }
        return CL;
    }

    private static NEdata loadGMPV3Fan(NEdata data, StringBuilder line) {
        String Line = "";
        Scanner scanner = new Scanner(line.toString());
        while (scanner.hasNext()) {
            Line = scanner.nextLine().trim();
            if (Line.indexOf("ManagedElement") <= -1) continue;
            MagList MAG = new MagList();
            MAG.Type = "FANU";
            MAG.MAGNo = GetDataFromMGW.get_col(Line, "=", 4);
            TypeOfSub MagData = new TypeOfSub();
            MagData = MagL.getMagData(MAG.MAGNo, "3");
            MAG.XPos = MagData.POS;
            MAG.BrNo = MAG.MAGNo;
            String Cabinet_num = MagData.Cab_No;
            int n = GetDataFromMGW.existCab(data, Cabinet_num);
            if (n <= -1) continue;
            data.getCAB(n).addMAG(MAG);
        }
        return data;
    }

    private static NEdata loadGMPV4Fan(NEdata data, StringBuilder line) {
        String Line = "";
        Scanner scanner = new Scanner(line.toString());
        while (scanner.hasNext()) {
            Line = scanner.nextLine().trim();
            if (Line.indexOf("ManagedElement") <= -1) continue;
            MagList MAG = new MagList();
            MAG.Type = "FANU";
            MAG.MAGNo = GetDataFromMGW.get_col(Line, "=", 5);
            TypeOfSub MagData = new TypeOfSub();
            MagData = MagL.getMagData(MAG.MAGNo, "4");
            MAG.XPos = MagData.POS;
            MAG.BrNo = MAG.MAGNo;
            String Cabinet_num = MagData.Cab_No;
            int n = GetDataFromMGW.existCab(data, Cabinet_num);
            if (n <= -1) continue;
            data.getCAB(n).addMAG(MAG);
        }
        return data;
    }

    private static NEdata loadMGWGlobal(StringBuilder line) {
        NEdata CL = new NEdata();
        String Line = "";
        String productName = "";
        String productNumber = "";
        String productRevision = "";
        Scanner scanner = new Scanner(line.toString());
        while (scanner.hasNext()) {
            Line = scanner.nextLine().trim();
            if (Line.indexOf("productName") > -1) {
                productName = GetDataFromMGW.get_col(Line, "\"", 2);
            }
            if (Line.indexOf("productNumber") > -1) {
                productNumber = GetDataFromMGW.get_col(Line, "\"", 2);
            }
            if (Line.indexOf("productRevision") <= -1) continue;
            productRevision = GetDataFromMGW.get_col(Line, "\"", 2);
        }
        CL.APZ = productName;
        CL.APT = String.valueOf(productNumber) + " " + productRevision;
        CL.AGM = "";
        return CL;
    }

    private static int existCab(NEdata data, String CabName) {
        int rez = -1;
        for (int i = 0; i < data.getCABCount(); ++i) {
            if (!data.getCAB((int)i).CabNo.equalsIgnoreCase(CabName)) continue;
            rez = i;
        }
        return rez;
    }

    private static int[] existMag(NEdata data, String BrNo) {
        int[] rez = new int[]{-1, -1};
        for (int i = 0; i < data.getCABCount(); ++i) {
            for (int k = 0; k < data.getCAB(i).getMAGCount(); ++k) {
                if (!data.getCAB((int)i).getMAG((int)k).BrNo.equalsIgnoreCase(BrNo)) continue;
                rez[0] = i;
                rez[1] = k;
            }
        }
        return rez;
    }

    private static NEdata loadCurrentBoards(NEdata data, StringBuilder line) {
        String Board_BUSCONN = "";
        String Board_EMlist = "";
        String Board_EQM = "";
        String Board_MANDATE = "";
        String Board_MASTRP = "";
        String Board_Name = "";
        String Board_PRODNAM = "";
        String Board_PRODNO = "";
        String Board_PRODREV = "";
        String Board_RPaddr = "";
        String Board_SERNO = "";
        String Board_Slot = "";
        String Board_State = "";
        String Line = "";
        Scanner scanner = new Scanner(line.toString());
        String tmp = "";
        while (scanner.hasNext()) {
            Line = scanner.nextLine().trim();
            if (Line.indexOf("activeSwAllocation=(Ref)") > -1) {
                tmp = GetDataFromMGW.get_col(Line, ",", 3);
                Board_EQM = GetDataFromMGW.get_col(tmp, "=", 2);
            }
            if (Line.indexOf("productionDate=") > -1) {
                Board_MANDATE = GetDataFromMGW.get_col(Line, "\"", 2);
            }
            if (Line.indexOf("Subrack") > -1) {
                tmp = GetDataFromMGW.get_col(Line, ",", 3);
                Board_MASTRP = GetDataFromMGW.get_col(tmp, "=", 2);
                tmp = GetDataFromMGW.get_col(Line, ",", 4);
                Board_RPaddr = GetDataFromMGW.get_col(tmp, "=", 2);
            }
            if (Line.indexOf("productName=") > -1) {
                Board_Name = GetDataFromMGW.get_col(Line, "\"", 2);
                Board_PRODNAM = GetDataFromMGW.get_col(Line, "\"", 2);
            }
            if (Line.indexOf("productNumber=") > -1) {
                Board_PRODNO = GetDataFromMGW.get_col(Line, "\"", 2);
            }
            if (Line.indexOf("productRevision=") > -1) {
                Board_PRODREV = GetDataFromMGW.get_col(Line, "\"", 2);
            }
            if (Line.indexOf("serialNumber=") > -1) {
                Board_SERNO = GetDataFromMGW.get_col(Line, "\"", 2);
            }
            if (Line.indexOf("SlotId=") > -1) {
                Board_Slot = GetDataFromMGW.get_col(Line, "\"", 2);
            }
            if (Line.indexOf("slotState=") <= -1) continue;
            Board_State = GetDataFromMGW.get_col(Line, ")", 2);
        }
        if (Board_State.equalsIgnoreCase("1")) {
            BoardList NewBoard = new BoardList();
            NewBoard.BUSCONN = Board_BUSCONN;
            NewBoard.EMlist = Board_EMlist;
            NewBoard.EQM = Board_EQM;
            NewBoard.MANDATE = Board_MANDATE;
            NewBoard.MASTRP = Board_MASTRP;
            NewBoard.Name = Board_Name;
            NewBoard.PRODNAM = Board_PRODNAM;
            NewBoard.PRODNO = Board_PRODNO;
            NewBoard.PRODREV = Board_PRODREV;
            NewBoard.RPaddr = Board_RPaddr;
            NewBoard.SERNO = Board_SERNO;
            NewBoard.Slot = Board_Slot;
            NewBoard.State = "WO";
            int[] CabNum = GetDataFromMGW.existMag(data, Board_MASTRP);
            if (CabNum[0] != -1 & CabNum[1] != -1) {
                data.getCAB(CabNum[0]).getMAG(CabNum[1]).addBoard(NewBoard);
            }
        }
        return data;
    }

    private static String ReturnCorrectNameGMPV3(String name) {
        String rezd = "";
        if (name.equalsIgnoreCase("1")) {
            rezd = "MAIN";
        }
        if (name.equalsIgnoreCase("2")) {
            rezd = "MOD1";
        }
        if (name.equalsIgnoreCase("3")) {
            rezd = "MOD2";
        }
        if (name.equalsIgnoreCase("4")) {
            rezd = "MOD3";
        }
        if (name.equalsIgnoreCase("5")) {
            rezd = "MOD4";
        }
        if (name.equalsIgnoreCase("6")) {
            rezd = "MOD5";
        }
        return rezd;
    }

    private static NEdata loadCurrentSubrack(NEdata data, StringBuilder line) {
        String Cabinet_row = "";
        String Cabinet_num = "";
        String Subrack_pos = "";
        String Subrack_type = "MGW";
        String Subrack_MAGno = "";
        String Subrack_BrNo = "";
        String Line = "";
        TypeOfSub MagData = new TypeOfSub();
        Scanner scanner = new Scanner(line.toString());
        while (scanner.hasNext()) {
            String tmp;
            Line = scanner.nextLine().trim();
            if (Line.indexOf("cabinetPosition") > -1) {
                tmp = GetDataFromMGW.get_col(Line, "\"", 2);
                Cabinet_row = GetDataFromMGW.get_col(tmp, "*", 1);
            }
            if (Line.indexOf("subrackPosition") > -1) {
                tmp = GetDataFromMGW.get_col(Line, "\"", 2);
                if (data.APT.indexOf("GMPV4") > -1) {
                    MagData = MagL.getMagData(tmp, "4");
                    Cabinet_num = MagData.Cab_No;
                    Subrack_pos = MagData.POS;
                    Subrack_MAGno = tmp;
                }
            }
            if (Line.indexOf("SubrackId") <= -1) continue;
            Subrack_BrNo = GetDataFromMGW.get_col(Line, "\"", 2);
            if (data.APT.indexOf("GMPV3") <= -1) continue;
            String MagName = GetDataFromMGW.ReturnCorrectNameGMPV3(Subrack_BrNo);
            MagData = MagL.getMagData(MagName, "3");
            Cabinet_num = MagData.Cab_No;
            Subrack_pos = MagData.POS;
            Subrack_MAGno = MagName;
        }
        int n = GetDataFromMGW.existCab(data, Cabinet_num);
        MagList MAG = new MagList();
        MAG.Type = Subrack_type;
        MAG.MAGNo = Subrack_MAGno;
        MAG.XPos = Subrack_pos;
        MAG.BrNo = Subrack_BrNo;
        if (Cabinet_num.length() > 0 & n == -1) {
            CabList newCabinet = new CabList();
            newCabinet.CabNo = Cabinet_num;
            newCabinet.CabRow = Cabinet_row;
            newCabinet.addMAG(MAG);
            data.addCAB(newCabinet);
        }
        if (Cabinet_num.length() > 0 & n > -1) {
            data.getCAB(n).addMAG(MAG);
        }
        return data;
    }
}

