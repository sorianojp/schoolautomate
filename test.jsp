<html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="./css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<body>

<%@ page language="java" import="utility.*, java.util.Vector, java.sql.*" %>
<%
utility.DBOperation dbOP = new utility.DBOperation();
utility.DBOperation dbOP2 = new utility.DBOperation();
WebInterface WI = new WebInterface(request);

Class.forName("net.sourceforge.jtds.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:jtds:sqlserver://localhost:1433;DatabaseName=SB_DATAMIGRATE;", "sa", "123");
dbOP2 = new DBOperation(con);

java.sql.ResultSet rs = null;
String strSQLQuery = "select studid,subjnam, subjtitl, subjcre, scyer1,cursem,  grade1, grade2 from grecords order by stud_id_int";
rs  = dbOP.executeQuery(strSQLQuery);

String strSQLQuery2 = "insert into _migrate_grade (stud_id, sub_code, sub_name, credit, sch_yr, cur_sem, grade1, grade2) values (";
String strSQLQuery3 = null;int iCount = 0;
while(rs.next()){
	strSQLQuery3 = strSQLQuery2 + WI.getInsertValueForDB(rs.getString(1), true, null)+","+
	WI.getInsertValueForDB(rs.getString(2), true, null)+","+
	WI.getInsertValueForDB(rs.getString(3), true, null)+","+
	WI.getInsertValueForDB(rs.getString(4), true, null)+","+
	WI.getInsertValueForDB(rs.getString(5), true, null)+","+
	WI.getInsertValueForDB(rs.getString(6), true, null)+","+
	WI.getInsertValueForDB(rs.getString(7), true, null)+","+
	WI.getInsertValueForDB(rs.getString(8), true, null)+")";
	System.out.println(dbOP2.executeUpdateWithTrans(strSQLQuery3, null, null, false)+"; "+iCount);
	++iCount;
}
rs.close();
%>

</body>
</html>
<%
dbOP.cleanUP();
dbOP2.cleanUP();
%>