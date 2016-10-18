package com.assignment5;
import java.sql.*;
/**
 * Created by Andrew on 10/17/2016.
 */
public class FindAllAncestor {
    public static void main(String[] args) {
        Connection con = null;

        final String username = args[0];      // username
        final String password = args[1];      // password
        final String seedPersonId = args[2];  // person id to get prerequisites for

        try {
            //
            // load driver class object
            //
            Class.forName("org.postgresql.Driver");

            //
            // create a connection (session) to the database
            //    connection string = "jdbc:progresql:<database URL:port number>/<database name>"
            //
            con = DriverManager.getConnection("jdbc:postgresql://ec2-52-88-214-84.us-west-2.compute.amazonaws.com:5432/cs452", username, password);

            new FindAllAncestor().runJavaTest(con, seedPersonId);

            if (null == con) {
                System.out.println("failed to connect");
                return;
            }
        }
        catch (ClassNotFoundException | SQLException ex) {
            ex.printStackTrace();
            return;
        }
        finally {
            //
            // clean up open resources
            // (result sets are automatically closed with their associated statements)
            //
            try {
                if (stmt != null) {
                    stmt.close();
                }
                if (pstmtInitItrTable != null) {
                    pstmtInsertIntoItrTable.close();
                }
                if (pstmtInsertIntoResTable != null) {
                    pstmtInsertIntoResTable.close();
                }
                if (pstmtDeleteFromItrTable != null) {
                    pstmtDeleteFromItrTable.close();
                }
                if (pstmtInsertIntoItrTable != null) {
                    pstmtInsertIntoItrTable.close();
                }
                if (pstmtInsertIntoTmpTable != null) {
                    pstmtInsertIntoTmpTable.close();
                }
                if (pstmtSelectFromResTable != null) {
                    pstmtSelectFromResTable.close();
                }
                if (con != null) {
                    con.createStatement().executeUpdate("drop table if exists res_table;");
                    con.createStatement().executeUpdate("drop table if exists itr_table;");
                    con.createStatement().executeUpdate("drop table if exists tmp_table;");
                    con.close();
                }
            }
            catch (SQLException ex) {
                System.out.println(ex.getMessage());
            }
        }

    }

    private static Statement stmt = null;
    private static ResultSet rs = null;
    //
    // PreparedStatement instances
    //
    private static PreparedStatement pstmtInitItrTable = null;
    private static PreparedStatement pstmtInsertIntoResTable = null;
    private static PreparedStatement pstmtInsertIntoTmpTable = null;
    private static PreparedStatement pstmtDeleteFromItrTable = null;
    private static PreparedStatement pstmtInsertIntoItrTable = null;
    private static PreparedStatement pstmtDeleteFromTmpTable = null;
    private static PreparedStatement pstmtSelectFromResTable = null;
    private static PreparedStatement pstmtSelectCountFromResTable = null;



    private void runJavaTest(Connection con, String seedPersonId) {
        //
        // SQL strings
        //
        final String SQL_CREATE_RES_TABLE =  // accumulates prerequisites
                "create temporary table res_table("
                        + "    person_id varchar(10) unique);";

        final String SQL_CREATE_ITR_TABLE =  // holds prerequisites for current iteration
                "create temporary table itr_table("
                        + "    like res_table including all);";

        final String SQL_CREATE_TMP_TABLE =  // temporarily holds iteration prerequisites
                "create temporary table tmp_table("
                        + "    like res_table including all);";


        final String SQL_INIT_ITR_TABLE =  // initializes the iteration table with first set of prereqs
                "insert into itr_table"
                        + "    select parent_id "
                        + "    from parent_child_db.parent_child "
                        + "    where child_id = ?;";

        final String SQL_INSERT_INTO_RES_TABLE =   // accumulates iteration prereqs
                "insert into res_table "
                        + "    select person_id "
                        + "    from itr_table;";

        final String SQL_DELETE_FROM_TMP_TABLE = "delete from tmp_table;";

        final String SQL_INSERT_INTO_TMP_TABLE =   // finds next set of prereqs
                "insert into tmp_table "
                        + "    (select parent_child_db.parent_child.parent_id "
                        + "     from itr_table, parent_child_db.parent_child "
                        + "     where itr_table.person_id = parent_child_db.parent_child.child_id "
                        + "           and parent_child_db.parent_child.parent_id is not null"
                        + "    )"
                        + "    except "   // exclude prereqs already accumulated, set operation eliminates duplications
                        + "   (select person_id "
                        + "    from res_table"
                        + "   );";

        final String SQL_DELETE_FROM_ITR_TABLE = "delete from itr_table;";

        final String SQL_INSERT_INTO_ITR_TABLE = // copies from temporary table into iteration table
                "insert into itr_table "
                        + "    select person_id "
                        + "    from tmp_table;";

        final String SQL_SELECT_FROM_RES_TABLE = "select * from res_table;";

        Statement stmt = null;
        //
        // PreparedStatement instances
        //
        PreparedStatement pstmtInitItrTable = null;
        PreparedStatement pstmtInsertIntoResTable = null;
        PreparedStatement pstmtInsertIntoTmpTable = null;
        PreparedStatement pstmtDeleteFromItrTable = null;
        PreparedStatement pstmtInsertIntoItrTable = null;
        PreparedStatement pstmtDeleteFromTmpTable = null;
        PreparedStatement pstmtSelectFromResTable = null;
        ResultSet rs = null;

        try {
            //
            // create the PreparedStatement instances
            //
            pstmtInitItrTable = con.prepareStatement(SQL_INIT_ITR_TABLE);               // inits the iteration table
            pstmtInsertIntoResTable = con.prepareStatement(SQL_INSERT_INTO_RES_TABLE);  // accumulates the results
            pstmtDeleteFromTmpTable = con.prepareStatement(SQL_DELETE_FROM_TMP_TABLE);  // cleans out tmp table
            pstmtInsertIntoTmpTable = con.prepareStatement(SQL_INSERT_INTO_TMP_TABLE);  // gets next round of prereqs
            pstmtDeleteFromItrTable = con.prepareStatement(SQL_DELETE_FROM_ITR_TABLE);  // cleans out the tmp table
            pstmtInsertIntoItrTable = con.prepareStatement(SQL_INSERT_INTO_ITR_TABLE);  // copies from tmp to itr table
            pstmtSelectFromResTable = con.prepareStatement(SQL_SELECT_FROM_RES_TABLE);  // get accumulated results
            //
            // create the local tables
            //    res_table: accumulates the results (course prerequisites)
            //    itr_table: holds prerequisites for current loop iteration
            //    tmp_table: temporarily hold prerequisites
            //
            con.createStatement().executeUpdate(SQL_CREATE_RES_TABLE);
            con.createStatement().executeUpdate(SQL_CREATE_ITR_TABLE);
            con.createStatement().executeUpdate(SQL_CREATE_TMP_TABLE);


            long start = System.nanoTime();
            //
            // initialize the iter table with first set of prerequisites
            //
            pstmtInitItrTable.setString(1, seedPersonId);
            pstmtInitItrTable.executeUpdate();
            //
            // enter the iteration loop
            //
            do {
                pstmtInsertIntoResTable.executeUpdate();  // accumulate the prerequisites
                pstmtDeleteFromTmpTable.executeUpdate();  // clean out the temporary table from previous iteration
                pstmtInsertIntoTmpTable.executeUpdate();  // insert new prerequisites into temporary table
                pstmtDeleteFromItrTable.executeUpdate();  // clean out the iteration table from previous iteration
            } while (0 < pstmtInsertIntoItrTable.executeUpdate()); // copy into iteration table, exit if no tuples

            rs = pstmtSelectFromResTable.executeQuery();

            double delta = (double)(System.nanoTime() - start) / 1000.0;

            System.out.println("-----------------------------------------------------");
            System.out.println(String.format("\n%-25s%,15.2f microseconds", "Find All Prereq Java", delta));
            System.out.println("-----------------------------------------------------");
            //
            // get result set from result accumulation table and print out prerequisites
            //
            int count = 0;
            while (rs.next()) {
                System.out.println(rs.getString(1));
                count++;
            }
            System.out.println("-----------------------------------------------------\n");
            System.out.println(String.format("Ancestors: %d\n",count));

        }
        catch (SQLException ex) {
            ex.printStackTrace();
        }
        finally {
            //
            // clean up open resources
            // (result sets are automatically closed with their associated statements)
            //
            try {
                if (stmt != null) {
                    stmt.close();
                }
                if (pstmtInitItrTable != null) {
                    pstmtInsertIntoItrTable.close();
                }
                if (pstmtInsertIntoResTable != null) {
                    pstmtInsertIntoResTable.close();
                }
                if (pstmtDeleteFromItrTable != null) {
                    pstmtDeleteFromItrTable.close();
                }
                if (pstmtInsertIntoItrTable != null) {
                    pstmtInsertIntoItrTable.close();
                }
                if (pstmtInsertIntoTmpTable != null) {
                    pstmtInsertIntoTmpTable.close();
                }
                if (pstmtSelectFromResTable != null) {
                    pstmtSelectFromResTable.close();
                }
                if (con != null) {
                    con.createStatement().executeUpdate("drop table if exists res_table;");
                    con.createStatement().executeUpdate("drop table if exists itr_table;");
                    con.createStatement().executeUpdate("drop table if exists tmp_table;");
                }
            }
            catch (SQLException ex) {
                System.out.println(ex.getMessage());
            }
        }
    }
}

