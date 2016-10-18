package com.assignment5;

import java.util.Arrays;
import java.util.List;

public class Main {

    public static void main(String[] args) {
        String idGenderFilePath = args[0];
        String idParentChildPath = args[1];

        System.out.println(idGenderFilePath);
        System.out.println(idParentChildPath);

        List<String[]> idGenderFileRaw = CSVReader.readFile(idGenderFilePath);
        List<String[]> parentChildRaw = CSVReader.readFile(idParentChildPath);

//        for (String[] line: idGenderFileRaw) {
//            System.out.println(Arrays.toString(line));
//        }

//        DbInsert.insert("id_gender", idGenderFileRaw);
        DbInsert.insert("parent_child", parentChildRaw);
    }
}
