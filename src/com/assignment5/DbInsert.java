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

    private static String SCHEMA_NAME = "parent_child_db";
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

            List<String> columnNames = new ArrayList<>(Arrays.asList(tableData.get(0)));

            final String createIdGenderTableQuery = "CREATE TABLE IF NOT EXISTS " + SCHEMA_NAME + ".id_gender\n" +
                    " (person_id varchar(8), \n" +
                    "  gender varchar(8), \n" +
                    "  PRIMARY KEY (person_id) \n"+
                    " );";

            final String createParentChildTableQuery = "CREATE TABLE IF NOT EXISTS " + SCHEMA_NAME + ".parent_child\n" +
                    " (child_id varchar(8), \n" +
                    "  parent_id varchar(8), \n" +
                    "  FOREIGN KEY (child_id) REFERENCES " + SCHEMA_NAME + ".id_gender (person_id)\n" +
                    "   ON DELETE SET NULL,\n" +
                    "  FOREIGN KEY (parent_id) REFERENCES " + SCHEMA_NAME + ".id_gender (person_id)\n" +
                    "   ON DELETE SET NULL\n" +
                    " );";

            PreparedStatement createTableStatement = con.prepareStatement(createIdGenderTableQuery);
            createTableStatement.execute();

            createTableStatement = con.prepareStatement(createParentChildTableQuery);
            createTableStatement.execute();

            StringBuilder insertQueryBuilder = new StringBuilder("INSERT INTO " + SCHEMA_NAME + "." + tableName + "(");
            StringBuilder insertValuesBuilder = new StringBuilder("VALUES (");

            StringJoiner columnJoiner = new StringJoiner(", ");
            StringJoiner valueJoiner = new StringJoiner(", ");

            for (String columnName: columnNames) {
                columnJoiner.add(columnName);
                valueJoiner.add("?");
            }

            insertValuesBuilder.append(valueJoiner).append(");");
            insertQueryBuilder.append(columnJoiner).append(")").append(insertValuesBuilder);

            String insertQuery = insertQueryBuilder.toString();
            PreparedStatement insertStatement = con.prepareStatement(insertQuery);

            for (int row = 1; row < tableData.size(); row++) {
                for (int column = 0; column < columnNames.size(); column++) {
                    insertStatement.setObject(column + 1, tableData.get(row)[column]);
                }
                insertStatement.execute();
                if (row % 100 == 0) {
                    System.out.println(row);
                }
            }

        } catch (ClassNotFoundException | SQLException ex) {
            ex.printStackTrace();
            return;
        }
    }
}
