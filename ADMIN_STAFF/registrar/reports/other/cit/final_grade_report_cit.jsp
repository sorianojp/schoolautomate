<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.print_to_excel.checked = false;
	document.form_.submit();
}

function PrintPage(){
	if(document.form_.print_to_excel.checked){		
		document.form_.submit();
		return;
	}
	document.bgColor = "#FFFFFF";

	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	
	document.getElementById("myADTable2").deleteRow(0);
	document.getElementById("myADTable2").deleteRow(0);
	document.getElementById("myADTable2").deleteRow(0);
	
	document.getElementById("myADTable3").deleteRow(0);
	
	document.getElementById("myADTable3").deleteRow(0);
	
	window.print();

}

</script>
<body>
<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	boolean bolShowData = true;
	if(WI.fillTextValue("print_to_excel").length() > 0)
		bolShowData = false;	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-TOP STUDENTS","final_grade_report_cit.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

String[] astrSortByName = {"ID Number","Last Name"};
String[] astrSortByVal = {"user_table.id_number","user_table.lname"};
	
ConstructSearch conSearch = new ConstructSearch();	
	
java.sql.ResultSet rs = null;
Vector vGradeInfo = new Vector();
Vector vEnrolled  = new Vector();
Vector vRetResult = new Vector();

String strSYFrom = WI.fillTextValue("sy_from");
String strSemester=  WI.fillTextValue("semester");
int iIndexOf = 0;
strTemp = WI.fillTextValue("student_list");
String strStudList = null;
int iCount  =0 ;
if(strTemp.length() > 0){
	while( (iIndexOf = strTemp.indexOf("\r\n")) > -1){
	
		strErrMsg = WI.getInsertValueForDB(strTemp.substring(0,iIndexOf), true, null);
	
		if(strStudList == null)
			strStudList = strErrMsg;
		else
			strStudList += ", "+ strErrMsg;		
			
		strTemp = strTemp.substring(iIndexOf+2);
	}
	
	if(strStudList == null)
		strStudList = WI.getInsertValueForDB(strTemp, true, null);
	else
		strStudList += ", "+ WI.getInsertValueForDB(strTemp, true, null);
}
strErrMsg = null;
if(strStudList != null && strStudList.length() > 0 && strSYFrom.length() > 0 && strSemester.length() > 0){
	CommonUtil.setSubjectInEFCLTable(dbOP);
	
	String strTempTable = null;
    CreateTable CT = new CreateTable();
    strTempTable = CT.createUniqueTable(dbOP, "(ui int primary key)");
    if (strTempTable == null)
    	strErrMsg = "Error in creating temp storage.";
	else{
		String strSQLQuery = "insert into "+strTempTable+" select user_index from USER_TABLE where ID_NUMBER in ("+strStudList+") ";
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
		
		strSQLQuery = "select user_index, sub_index, sub_code, sub_name from enrl_final_cur_list join " + strTempTable + 
			" on (user_index = ui) join subject on (subject.sub_index = efcl_sub_index) where sy_from = " + strSYFrom + 
			" and current_semester = " + strSemester + 
			" and is_temp_stud = 0 and is_valid = 1 order by user_index, sub_code, sub_name";
		rs = dbOP.executeQuery(strSQLQuery);
		while (rs.next()) {
			vEnrolled.addElement(new Integer(rs.getInt(1)));//[0]user_index
			vEnrolled.addElement(rs.getString(1) + "-" + rs.getString(2));//[1]user_index-sub_index
			vEnrolled.addElement(rs.getString(3));//[2]sub_code
			vEnrolled.addElement(rs.getString(4));//[3]sub_name
			vEnrolled.addElement(null);//[4]
			vEnrolled.addElement(null);//[5]
		}rs.close();
		
		strSQLQuery = "select user_index_, s_index, grade, remark_abbr, credit_earned, sub_code, sub_name "+
			" from g_sheet_final "+
			" join stud_curriculum_hist on (stud_curriculum_hist.cur_hist_index = g_sheet_final.cur_hist_index) "+
			" join "+ strTempTable + " on (ui = user_index_ ) " + 
			" join remark_status on (remark_status.remark_index = g_sheet_final.remark_index) " + 
			" join subject on (subject.sub_index = s_index) " + 
			" where sy_from = " + strSYFrom + 
			" and semester = " + strSemester + 
			" and g_sheet_final.is_valid = 1 order by user_index_, sub_code, sub_name";

			String strGrade = null;
			rs = dbOP.executeQuery(strSQLQuery);
			while (rs.next()) {
				strGrade = rs.getString(3);
				if (strGrade == null) 
					strGrade = rs.getString(4);
				
				iIndexOf = vEnrolled.indexOf(rs.getString(1) + "-" + rs.getString(2));
				if (iIndexOf == -1) {
					iIndexOf = vEnrolled.indexOf(new Integer(rs.getInt(1)));
					if (iIndexOf != -1){
						vEnrolled.addElement(new Integer(rs.getInt(1)));
						vEnrolled.addElement(rs.getString(1) + "-" + rs.getString(2));
						vEnrolled.addElement(rs.getString(6));
						vEnrolled.addElement(rs.getString(7));
						vEnrolled.addElement(strGrade);
						vEnrolled.addElement(rs.getString(5));
					}
				}
				else {
					vEnrolled.setElementAt(strGrade, iIndexOf + 3);
					vEnrolled.setElementAt(rs.getString(5), iIndexOf + 4);
				}
			}rs.close();
			
			if (vEnrolled.size() < 2) 
				strErrMsg = "No result found.";
			else{			
				
				String[] astrSortByFieldName = {WI.fillTextValue("sort_by1"), WI.fillTextValue("sort_by2")};
		
				String[] astrAscDesc = {WI.fillTextValue("sort_by1_con"),WI.fillTextValue("sort_by2_con")};
		
				String strSortCon = conSearch.constructSortByCondition(astrSortByFieldName, astrAscDesc);
				if(strSortCon == null || strSortCon.length() == 0)
					strSortCon = " order by lname, fname, mname ";
			
			
				strSQLQuery = " select user_table.user_index, id_number, fname, mname, lname , "+
					" course_offered.course_code, year_level "+
					" from stud_curriculum_hist  "+
					" join " + strTempTable + " on (ui = stud_curriculum_hist.user_index ) " + 
					" join user_table on (user_table.user_index = stud_curriculum_hist.user_index) " + 
					" left join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) " + 
					" left join major on (major.major_index = stud_curriculum_hist.major_index) " + 
					" where stud_curriculum_hist.is_valid = 1 and sy_from = " + strSYFrom + " and semester = " + strSemester + strSortCon;

				
				rs = dbOP.executeQuery(strSQLQuery);
				while (rs.next()) {
					vRetResult.addElement(rs.getString(1));//[0]
					vRetResult.addElement(rs.getString(2));//[1]
					vRetResult.addElement(WebInterface.formatName(rs.getString(3), rs.getString(4), rs.getString(5), 4));//[2]
					vRetResult.addElement(rs.getString(6));//[3]
					vRetResult.addElement(rs.getString(7));//[4]					
					vGradeInfo = new Vector();
					while (true) {
						iIndexOf = vEnrolled.indexOf(new Integer(rs.getInt(1)));
						if (iIndexOf == -1)
							break;
							
						vGradeInfo.addElement(vEnrolled.elementAt(iIndexOf + 2));
						vGradeInfo.addElement(vEnrolled.elementAt(iIndexOf + 3));
						vGradeInfo.addElement(vEnrolled.elementAt(iIndexOf + 4));
						vGradeInfo.addElement(vEnrolled.elementAt(iIndexOf + 5));
						
						vEnrolled.removeElementAt(iIndexOf); vEnrolled.removeElementAt(iIndexOf); vEnrolled.removeElementAt(iIndexOf);
						vEnrolled.removeElementAt(iIndexOf); vEnrolled.removeElementAt(iIndexOf); vEnrolled.removeElementAt(iIndexOf);
					}				
					vRetResult.addElement(vGradeInfo);//[5]
				}
				rs.close();
				
			
			
			}
	}
}


	
%>

<form name="form_" action="./final_grade_report_cit.jsp" method="post">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: 
        FINAL GRADE REPORT PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" ><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
   
   
   <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td width="12%" height="25" >SY/Term </td>
      <td width="85%" >
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
		  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		readonly="yes">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<select name="semester">
	<%=CommonUtil.constructTermList(dbOP, request, WI.fillTextValue("semester"))%>
    </select></td>
    </tr>
   <tr>
       <td height="25" >&nbsp;</td>
       <td height="25"  valign="bottom">&nbsp;</td>
       <td>
	   <font size="1">
	   ID Format sample: <br>
	   2009-00001<br>	   
	   2009-00002<br>
	   2009-00003
	   </font>
	   </td>
   </tr>
   <tr>
       <td height="25" >&nbsp;</td>
       <td height="25"  valign="bottom">Student ID</td>
	   <%
	   strTemp = WI.fillTextValue("student_list");
	   %>
       <td>
	   <textarea name="student_list" cols="60" rows="3"><%=strTemp%></textarea>	   
	   
	   	   </td>
   </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
		<tr>
          	<td height="25" width="3%">&nbsp;</td>
		  	<td width="12%">Sort by: </td>
		  	<td width="20%">
				<select name="sort_by1">
					<option value="">N/A</option>
					<%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
			</select></td>
		    <td width="17%">
				<select name="sort_by2">
              		<option value="">N/A</option>
             		<%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
			</select></td>
		    <td width="48%">
				<select name="sort_by3">
					<option value="">N/A</option>
              		<%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
           	</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>&nbsp;</td>
		    <td>
				<select name="sort_by1_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
				</select></td>
			<td>
				<select name="sort_by2_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
            	</select></td>
			<td>
				<select name="sort_by3_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
            	</select></td>
		</tr>
		
		
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="4">
			
			
	Rows Per Page: 
	  <select name="rows_per_pg">
	  <option value="100000">Print All</option>
<%
int iDefVal = 0;
if(WI.fillTextValue("rows_per_pg").length() > 0)
	iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
for(int i = 20; i < 70; ++i) {
	if(iDefVal == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
	<option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>
	  &nbsp;&nbsp;
			
			<input type="image" name="search" src="../../../../../images/form_proceed.gif" onClick="ReloadPage();" border="0">			</td>
		</tr>
	</table>
<%
if(vRetResult != null && vRetResult.size() > 0){

utility.CreateExcelSheet ces = new utility.CreateExcelSheet();
ces.dontCreateFile(bolShowData);
ces.createFile(dbOP, request, "CITFinalGradeSummary");	
ces.createNewSheet("Summary");


%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable3">
	<%
	if(bolShowData){
	%>
	<tr>
	<td align="right">
	<%
	/*strTemp = WI.fillTextValue("print_to_excel");
	if(strTemp.equals("1"))
		strErrMsg = "checked";
	else
		strErrMsg  = "";*/
	%><!--<input type="checkbox" name="print_to_excel" value="1" <%=strErrMsg%>>Import to excel-->
	&nbsp; &nbsp;
	<a href="javascript:PrintPage();"><img src="../../../../../images/print.gif" border="0"></a>
	<font size="1">Click to print report</font>	</td>
	</tr>
	<%}%>
</table>
<%
int iMaxRowCount = 100000;
if(WI.fillTextValue("rows_per_pg").length() > 0)
	iMaxRowCount = Integer.parseInt(WI.fillTextValue("rows_per_pg"));

	
	
int iRowCount = 0;

boolean bolPageBreak = false;
String[] astrConvertSem = {"Summer", "First Semester", "Second Semester", "Third Semester", "Fourth Semester"};
String strSchName = SchoolInformation.getSchoolName(dbOP, true, false);
String strSchAdd  = SchoolInformation.getAddressLine1(dbOP, false, false);

int iSubLine = 0;
Vector vSubList = null;
for(int i =0 ; i < vRetResult.size() ;){	
iRowCount = 0;
if(bolPageBreak){bolPageBreak=false;%>
	<div style="page-break-after:always;">&nbsp;</div>
<%}
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<%	
	ces.setFontSize(13);				
	ces.setBold(true);
	ces.setBorder(0);
	ces.setBorderLineStyle(0);
	ces.setAlignment(1);
	
	if(i > 0)
		ces.addData("&nbsp;", true, 11, 0);	
	
	ces.addData(strSchName, true, 11, 0);
	
	ces.setFontSize(11);	
	
	
	
	ces.addData(strSchAdd, true, 11, 0);
	ces.addData("TOP STUDENT GRADE SUMMARY", true, 11, 0);
	strTemp = astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))] + " " + WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to");
	ces.addData(strTemp, true, 11, 0);
	if(bolShowData){
	%>
	<tr>
		<td align="center">
		<font style="font-size:14px; font-weight:bold;"><%=strSchName%></font><br>
		<font style="font-size:12px;"><%=strSchAdd%></font><br><br>
		TOP STUDENT GRADE SUMMARY<br>
		<%=strTemp%><!--sy-term-->		</td>
	</tr>
	<%}%>
</table>

<%
ces.setFontSize(10);
ces.setAlignment(0);
if(bolShowData)
	strTemp = "class='thinborder'";
else
	strTemp = "";
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" <%=strTemp%> bgcolor="#FFFFFF">

	<%
	
	for(; i < vRetResult.size(); ){	
	++iRowCount;		
	vSubList = (Vector) vRetResult.elementAt(i+5);	
	iSubLine = ((vSubList.size() / 4)/5);
	if(iSubLine <= 0)
		iSubLine = 1;

	if(iRowCount + (iSubLine - 1) > iMaxRowCount){
		bolPageBreak = true;
		break;
	}
	%>
	<tr>	
		<%	
		ces.setAlignment(0);	
		ces.addData((String)vRetResult.elementAt(i+1), false);
		ces.addData((String)vRetResult.elementAt(i+2), false);
		if(bolShowData){
		%>
	    <td width="16%" height="20" class="thinborder"><%=vRetResult.elementAt(i+1)%></td> 	
		<td width="34%" class="thinborder"><%=vRetResult.elementAt(i+2)%></td>
		<%}
		if(vSubList.size() > 0)
			strTemp = (String)vSubList.remove(0);
		else
			strTemp = "&nbsp;";		
		ces.setAlignment(0);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
		<td width="7%" class="thinborder"><%=strTemp%></td>
		<%	}
		if(vSubList.size() > 0){
			vSubList.remove(0);	
			strTemp = (String)vSubList.remove(0);
			vSubList.remove(0);
		}else
			strTemp = "&nbsp;";
		ces.setAlignment(1);
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
		<td width="3%" class="thinborder" align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>	
		
		<%}
		if(vSubList.size() > 0)
			strTemp = (String)vSubList.remove(0);
		else
			strTemp = "&nbsp;";	
		ces.setAlignment(0);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
		<td width="7%" class="thinborder"><%=strTemp%></td>
		<%}
		if(vSubList.size() > 0){
			vSubList.remove(0);	
			strTemp = (String)vSubList.remove(0);
			vSubList.remove(0);
		}else
			strTemp = "&nbsp;";
		ces.setAlignment(1);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
		<td width="3%" class="thinborder" align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>			
		<%}
		if(vSubList.size() > 0)
			strTemp = (String)vSubList.remove(0);
		else
			strTemp = "&nbsp;";	
		ces.setAlignment(0);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
		<td width="7%" class="thinborder"><%=strTemp%></td>
		<%}
		if(vSubList.size() > 0){
			vSubList.remove(0);	
			strTemp = (String)vSubList.remove(0);
			vSubList.remove(0);
		}else
			strTemp = "&nbsp;";
		ces.setAlignment(1);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
		<td width="3%" class="thinborder" align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>			
		<%}
		if(vSubList.size() > 0)
			strTemp = (String)vSubList.remove(0);
		else
			strTemp = "&nbsp;";	
		ces.setAlignment(0);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
		<td width="7%" class="thinborder"><%=strTemp%></td>
		<%}
		if(vSubList.size() > 0){
			vSubList.remove(0);	
			strTemp = (String)vSubList.remove(0);
			vSubList.remove(0);
		}else
			strTemp = "&nbsp;";
		ces.setAlignment(1);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
		<td width="3%" class="thinborder" align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>			
		<%}
		if(vSubList.size() > 0)
			strTemp = (String)vSubList.remove(0);
		else
			strTemp = "&nbsp;";	
		ces.setAlignment(0);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
		<td width="7%" class="thinborder"><%=strTemp%></td>
		<%}
		if(vSubList.size() > 0){
			vSubList.remove(0);	
			strTemp = (String)vSubList.remove(0);
			vSubList.remove(0);
		}else
			strTemp = "&nbsp;";
		ces.setAlignment(1);	
		ces.addData(strTemp, true);
		if(bolShowData){
		%>
		<td width="3%" class="thinborder" align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>		
		<%}%>
	</tr>
	<%
	while(vSubList.size() > 0){
	++iRowCount;
	%>
	<tr><%
		strTemp = "&nbsp;";
		ces.addData(strTemp, false);
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
	    <td height="20" class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
		<%}
		if(vSubList.size() > 0)
			strTemp = (String)vSubList.remove(0);
		else
			strTemp = "&nbsp;";	
		ces.setAlignment(0);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
	    <td class="thinborder"><%=strTemp%></td>
		<%	}
		if(vSubList.size() > 0){
			vSubList.remove(0);	
			strTemp = (String)vSubList.remove(0);
			vSubList.remove(0);
		}else
			strTemp = "&nbsp;";
		ces.setAlignment(1);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
	    <td class="thinborder" align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>		
		<%}
		if(vSubList.size() > 0)
			strTemp = (String)vSubList.remove(0);
		else
			strTemp = "&nbsp;";	
		ces.setAlignment(0);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
	    <td class="thinborder"><%=strTemp%></td>
		<%	}
		if(vSubList.size() > 0){
			vSubList.remove(0);	
			strTemp = (String)vSubList.remove(0);
			vSubList.remove(0);
		}else
			strTemp = "&nbsp;";
		ces.setAlignment(1);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
	    <td class="thinborder" align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%}
		if(vSubList.size() > 0)
			strTemp = (String)vSubList.remove(0);
		else
			strTemp = "&nbsp;";	
		ces.setAlignment(0);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
	    <td class="thinborder"><%=strTemp%></td>
		<%}
		if(vSubList.size() > 0){
			vSubList.remove(0);	
			strTemp = (String)vSubList.remove(0);
			vSubList.remove(0);
		}else
			strTemp = "&nbsp;";
		ces.setAlignment(1);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
	    <td class="thinborder" align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%}
		if(vSubList.size() > 0)
			strTemp = (String)vSubList.remove(0);
		else
			strTemp = "&nbsp;";	
		ces.setAlignment(0);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
	    <td class="thinborder"><%=strTemp%></td>
		<%}
		if(vSubList.size() > 0){
			vSubList.remove(0);	
			strTemp = (String)vSubList.remove(0);
			vSubList.remove(0);
		}else
			strTemp = "&nbsp;";
		ces.setAlignment(1);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
	    <td class="thinborder" align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%}
		if(vSubList.size() > 0)
			strTemp = (String)vSubList.remove(0);
		else
			strTemp = "&nbsp;";	
		ces.setAlignment(0);	
		ces.addData(strTemp, false);
		if(bolShowData){
		%>
	    <td class="thinborder"><%=strTemp%></td>
		<%}
		if(vSubList.size() > 0){
			vSubList.remove(0);	
			strTemp = (String)vSubList.remove(0);
			vSubList.remove(0);
		}else
			strTemp = "&nbsp;";
		ces.setAlignment(1);	
		ces.addData(strTemp, true);
		if(bolShowData){
		%>
	    <td class="thinborder" align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%}%>
		
    </tr>	
	<%}//end while(vSubList.size() > 0)
	
	i+=6;
	if(iRowCount > iMaxRowCount){
		bolPageBreak = true;
		break;
	}	
		
	}%>	
</table>
<%}//end of for loop




ces.writeAndClose(request);
if(!bolShowData){
	strTemp = "../../../../../download/CITFinalGradeSummary_"+WI.getTodaysDate()+".xls";
%>
	<a href="<%=strTemp%>">Click to download excel file</a>
<%}

}
%>
<input type="hidden" name="installDir" value="installDir">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
