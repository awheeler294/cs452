package edu.byu.cs.cs452;

import java.sql.*;

/**
 * Created by johnsonrc on 10/8/2015.
 */
public class Fibonacci {
  public static void main(String[] args) {
    new Fibonacci().run(args);
  }

  private static String SQL_FIB_FUNCTION =
      "select f_fib(?,?,?);";

  private static String SQL_FIB_FUNCTION_LOOP =
      "select f_fib_loop(?,?,?);";

  private static String SQL_FIB_RECURSIVE_QUERY =
      "with recursive r_fib(a, b, c) as ("
    + "        select ?,?,? "
    + "    union "
    + "        select b, a+b, c-1 "
    + "        from r_fib "
    + "        where c > 1 "
    + "    ) "
    + "select a "
    + "from r_fib "
    + "where c = 1;";

  private static String SQL_FIB_FUNCTION_RC =
      "select f_fib_rc(?,?,?);";

  private long r_fib(long a, long b, int c) {
    if (c < 1)
      return 0;
    else if (c == 1)
      return a;
    else if (c == 2)
      return b;
    else
      return r_fib(b, a + b, c - 1);
  }

  private void runJavaTest(long a, long b, int c) {
    long start = System.nanoTime();
    long result = r_fib(a, b, c);
    double delta = (double)(System.nanoTime() - start) / 1000.0;

    System.out.println(String.format("%-25s%,15d%,15.2f microseconds", "Fib Java", result, delta));
  }

  private void runTest(String testName, PreparedStatement pstmt, long a, long b, int c) throws SQLException {
    pstmt.setLong(1, a);
    pstmt.setLong(2, b);
    pstmt.setInt(3, c);
    long start = System.nanoTime();
    ResultSet rs = pstmt.executeQuery();
    double delta = (double)(System.nanoTime() - start)/1000.0;

    if (rs.next()) {
      System.out.println(String.format("%-25s%,15d%,15.2f microseconds", testName, rs.getLong(1), delta));
    }
    else {
      System.out.println(String.format("%-25s -- no return value --", testName));
    }

    if (null != rs) {
      rs.close();
    }
  }

  private void run(String[] args) {
    Connection con = null;

    final String username = args[0];      // username
    final String password = args[1];      // password
    long a = Long.parseLong(args[2]);
    long b = Long.parseLong(args[3]);
    int c = Integer.parseInt(args[4]);

    PreparedStatement pstmtFibFunction = null;
    PreparedStatement pstmtFibFunctionLoop = null;
    PreparedStatement pstmtFibRecursiveQuery = null;
    PreparedStatement pstmtFibFunctionRC = null;

    ResultSet rs = null;
    try {
      //
      // load driver class object
      //
      Class.forName("org.postgresql.Driver");

      //
      // create a connection (session) to the database
      //    connection string = "jdbc:progresql:<database URL:port number>/<database name>"
      //
      con = DriverManager.getConnection("jdbc:postgresql://127.0.0.1:5432/cs452", username, password);
      if (null == con) {
        System.out.println("failed to connect");
        return;
      }

      pstmtFibFunction = con.prepareStatement(SQL_FIB_FUNCTION);
      pstmtFibFunctionLoop = con.prepareStatement(SQL_FIB_FUNCTION_LOOP);
      pstmtFibRecursiveQuery = con.prepareStatement(SQL_FIB_RECURSIVE_QUERY);
      pstmtFibFunctionRC = con.prepareStatement(SQL_FIB_FUNCTION_RC);

      runJavaTest(a, b, c);
      runTest("Fib Function", pstmtFibFunction, a, b, c);
      runTest("Fib Function Loop", pstmtFibFunctionLoop, a, b, c);
      runTest("Fib Recursive Query", pstmtFibRecursiveQuery, a, b, c);
      runTest("Fib Function RC", pstmtFibFunctionRC, a, b, c);
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
        if (pstmtFibFunction != null) {
          pstmtFibFunction.close();
        }
        if (pstmtFibFunctionLoop != null) {
          pstmtFibFunctionLoop.close();
        }
        if (pstmtFibRecursiveQuery != null) {
          pstmtFibRecursiveQuery.close();
        }
        if (pstmtFibFunctionRC != null) {
          pstmtFibFunctionRC.close();
        }
        if (con != null) {
          con.createStatement().executeUpdate("drop table if exists resTable;");
          con.createStatement().executeUpdate("drop table if exists itrTable;");
          con.createStatement().executeUpdate("drop table if exists tmpTable;");
          con.close();
        }
      }
      catch (SQLException ex) {
        System.out.println(ex.getMessage());
      }
    }
  }
}
