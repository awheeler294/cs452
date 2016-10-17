package com.assignment5;

import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.StringJoiner;

/**
 * Created by Andrew on 10/15/2016.
 */
public class DbInsert {

    private static String SCHEMA_NAME = "parent_child";
    private static String DB_USER = "andrew";
    private static String DB_PASS = "dangerwaffle";

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
            Connection con = DriverManager.getConnection("jdbc:postgresql://ec2-52-88-214-84.us-west-2.compute.amazonaws.com:5432/cs452", DB_USER, DB_PASS);
            if (null == con) {
                System.out.println("failed to connect");
                return;
            }

            int numColumns = tableData.get(0).length;

            List<String> columnNames = new ArrayList<>(Arrays.asList(tableData.get(0)));

            final String createTableQuery = "CREATE TABLE IF NOT EXIST " + SCHEMA_NAME + "." + tableName;
            PreparedStatement createTableStatement = con.prepareStatement(createTableQuery);
            createTableStatement.execute();

            StringBuilder insertQueryBuilder = new StringBuilder("INSERT INTO " + SCHEMA_NAME + "." + tableName + "(");
            StringBuilder insertValuesBuilder = new StringBuilder("VALUES (");

            StringJoiner columnJoiner = new StringJoiner(", ");
            StringJoiner valueJoiner = new StringJoiner(", ");

            for (String columnName: columnNames) {
                columnJoiner.add(columnName);
                valueJoiner.add("?");
            }

            insertValuesBuilder.append(valueJoiner).append(")");
            insertQueryBuilder.append(columnJoiner).append(")").append(insertValuesBuilder);

            String insertQuery = insertQueryBuilder.toString();
            PreparedStatement insertStatment = con.prepareStatement(insertQuery);

            for (int i = 1; i < tableData.size(); i++) {

            }

        } catch (ClassNotFoundException | SQLException ex) {
            ex.printStackTrace();
            return;
        }
    }
}
