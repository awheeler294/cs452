package com.assignment5;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

import java.util.*;

public class CSVReader {

    public static List<String[]> readFile(String filePath) {
        String line = "";
        String cvsSplitBy = ",";

        List<String[]> lines = new ArrayList<>();

        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            while ((line = br.readLine()) != null) {

                // use comma as separator
                String[] lineSplit = line.split(cvsSplitBy);

                lines.add(lineSplit);

            }

        } catch (IOException e) {
            e.printStackTrace();
        }

        return lines;
    }

}