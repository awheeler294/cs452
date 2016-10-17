package com.assignment5;

import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by Andrew on 10/15/2016.
 */
public class DbInsert {
    public DbInsert() {

    }

    public static void insert(String tableName, List<String[]> tableData) {
        try {
            //
            // load driver class object
            //
            Class.forName("org.postgresql.Driver");

            //
            // create a connection (session) to the database
            //    connection string = "jdbc:progresql:<database URL:port number>/<database name>"
            //
            Connection con = DriverManager.getConnection("jdbc:postgresql://ec2-52-88-214-84.us-west-2.compute.amazonaws.com:5432/cs452", "andrew", "dangerwaffle");
            if (null == con) {
                System.out.println("failed to connect");
                return;
            }

            int numColumns = tableData.get(0).length;

            List<String> columnNames = new ArrayList<>(Arrays.asList(tableData.get(0)));

            String createStatement = "CREATE TABLE IF NOT EXIST parent_child." + tableName;

            String

            for (int i = 1; i < tableData.size(); i++) {

            }

        } catch (ClassNotFoundException | SQLException ex) {
            ex.printStackTrace();
            return;
        }
    }
}
