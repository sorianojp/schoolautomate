<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<body topmargin="5">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,student.StudentEvaluation,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	double dGWA      = 0d;

	String[] astrConvertYear ={"","FIRST YEAR","SECOND YEAR","THIRD YEAR","FOURTH YEAR","FIFTH YEAR","SIXTH YEAR"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem","","","",""};
	String[] astrConvertResStatus = {"Regular","Irregular"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-STUDENT CURRICULUM EVALUATION","stud_cur_residency_eval.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","STUDENT COURSE EVALUATION",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
					"FACULTY/ACAD. ADMIN","STUDENTS PERFORMANCE",request.getRemoteAddr(),
					null);
}
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	//adviser are allowed to check.
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","ADVISING & SCHEDULING",request.getRemoteAddr(),
														"stud_cur_residency_eval_print.jsp");
	if(iAccessLevel == 0) {
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
}

//end of authenticaion code.
GradeSystem GS = new GradeSystem();
StudentEvaluation SE = new StudentEvaluation();
Vector vRetResult = null;
Vector vTemp = null;

if(WI.fillTextValue("stud_id").length() > 0) {
	vTemp = GS.getResidencySummary(dbOP, WI.fillTextValue("stud_id"));
	if(vTemp == null)
		strErrMsg = GS.getErrMsg();
	else {
		vRetResult = SE.getCurriculumResidencyEval(dbOP,(String)vTemp.elementAt(0),(String)vTemp.elementAt(15),
                                           (String)vTemp.elementAt(16),(String)vTemp.elementAt(8),(String)vTemp.elementAt(9),
                                           (String)vTemp.elementAt(11));
		if(vRetResult == null || vRetResult.size() ==0)
			strErrMsg = SE.getErrMsg();
	}

	//I have to get the GWA for all the subjects completed so far.
	student.GWA gwa = new student.GWA();
	dGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));
}
boolean bolRemoveRemark = false;
boolean bolShowGrade = false;
String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

bolShowGrade    = true;
bolRemoveRemark = true;


Vector vInProgress  = new Vector();

if(strErrMsg == null && vTemp != null && vTemp.size() > 0) { //save print information ::
	String strSYFrom   = (String)vTemp.elementAt(17);
	String strSemester = (String)vTemp.elementAt(18);

	String strSQLQuery = "select PRINT_INDEX from TRACK_PRINTING where STUD_INDEX = "+(String)vTemp.elementAt(0)+
		" and PRINT_MODULE = 2 and SY_FROM = "+strSYFrom +" and SEMESTER="+strSemester+" and DATE_PRINTED='"+
		WI.getTodaysDate()+"'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery == null) {
		strSQLQuery = "insert into TRACK_PRINTING (STUD_INDEX,PRINT_MODULE,SY_FROM,SEMESTER,DATE_PRINTED,PRINTED_BY) values ("+(String)vTemp.elementAt(0)+
			",2,"+strSYFrom+","+strSemester+",'"+WI.getTodaysDate()+"',"+(String)request.getSession(false).getAttribute("userIndex")+")";
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	}
	strSQLQuery = "select cur_index from enrl_final_cur_list where is_valid = 1 and user_index = "+vTemp.elementAt(0)+" and sy_from = "+
		strSYFrom+ " and current_semester="+strSemester+" and is_temp_stud = 0";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);//System.out.println(strSQLQuery);
	while(rs.next())
		vInProgress.addElement(rs.getString(1));
	rs.close();
}



%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="20" colspan="4"><div align="center"><strong>SOUTHEAST ASIAN
        COLLEGE, INC<br>
        Quezon City<br>
        </strong></div></td>
    </tr>
	</table>
<%if(strErrMsg != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="2%" height="20">&nbsp;</td>
      <td width="98%" height="20" colspan="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
<%}if(vTemp != null && vTemp.size()>0)
{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="10">&nbsp;</td>
    <td>Student ID</td>
    <td><%=WI.fillTextValue("stud_id")%></td>
    <td>Year</td>
    <td><strong><%=astrConvertYear[Integer.parseInt(WI.getStrValue(vTemp.elementAt(10),"0"))]%></strong></td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td width="15%">Student name</td>
    <td width="45%"><strong><%=WI.formatName((String)vTemp.elementAt(1),(String)vTemp.elementAt(2),(String)vTemp.elementAt(3),1)%></strong></td>
    <td width="10%">Entry Status</td>
    <td width="28%"><strong><%=(String)vTemp.elementAt(4)%></strong></td>
  </tr>
  <tr>
    <td width="2%" height="20">&nbsp;</td>
    <td>Course/Major</td>
    <td><strong><%=(String)vTemp.elementAt(6)%>/<%=WI.getStrValue(vTemp.elementAt(7))%> (<%=(String)vTemp.elementAt(8)%>-<%=(String)vTemp.elementAt(9)%>)</strong></td>
    <td> <% if (!((String)vTemp.elementAt(11)).equals("1") || !((String)vTemp.elementAt(11)).equals("2")){%>
      GWA :
      <%}%> &nbsp;</td>
    <td> <% if (!((String)vTemp.elementAt(11)).equals("1") || !((String)vTemp.elementAt(11)).equals("2")){%> <strong><%=CommonUtil.formatFloat(dGWA,false)%></strong> <%}%> &nbsp; </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td height="20"  colspan="2">Total units required for this course : <strong><%=(String)vTemp.elementAt(12)%></strong></td>
    <td height="20"  colspan="2">Total units taken : <strong><%=WI.getStrValue(vTemp.elementAt(13))%></strong></td>
  </tr>
</table>
<%}//only vTemp is not null -- having residency summary.
if(vRetResult != null){
String strPrevYr  = null;
String strCurYr   = null;
int iPrevSem = 0;
int iCurSem  = 0;

int i = 0;
double dTotalUnit = 0d;
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <%for(; i< vRetResult.size();){%>
  <tr>
    <td colspan="2" align="center"><FONT size="2">
	<strong><%=astrConvertYear[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i),"0"))]%></strong></FONT></td>
  </tr>
  <tr>
    <td width="50%" valign="top"> <%
	iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
	if(iCurSem == 1){dTotalUnit =0d;
	%> <table width="100%" cellpadding="0" cellspacing="0" border="0">
        <tr>
          <td colspan="4" align="center"><strong>First Semester</strong></td>
        </tr>
        <tr>
          <td width="20%"><strong>SUBJECT</strong></td>
          <td width="40%"><strong>DESCRIPTION</strong></td>
          <td width="18%"><strong>UNITS</strong></td>
          <td width="22%"><strong>GRADE</strong></td>
        </tr>
        <%for(; i< vRetResult.size();){//1st semester only.
		iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
		if(iCurSem != 1)
			break;
		dTotalUnit += Double.parseDouble((String)vRetResult.elementAt(i + 10));
		strTemp = WI.getStrValue(vRetResult.elementAt(i+14));
		if(strTemp.length() == 0) {
			int iIndexOf = vInProgress.indexOf(vRetResult.elementAt(i + 3));
			if(iIndexOf > -1) {
				strTemp = "IP";
			}
		}
		%>
        <tr>
          <td><%=(String)vRetResult.elementAt(i+4)%></td>
          <td><%=(String)vRetResult.elementAt(i+5)%></td>
          <td><%=(String)vRetResult.elementAt(i+10)%></td>
          <td><%=strTemp%></td>
        </tr>
        <%i += 16;}//prints only 1st semester. - Inner for loop%>
        <tr>
          <td>&nbsp;</td>
          <td><div align="right"><strong>TOTAL&nbsp;&nbsp;&nbsp;&nbsp;</strong></div></td>
          <td><strong><%=dTotalUnit%></strong></td>
          <td>&nbsp;</td>
        </tr>
      </table>
      <%}//only for 1st year.%> </td>
    <td width="50%" valign="top"> <%dTotalUnit =0d;
	iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
	if(iCurSem == 2){%> <table width="100%" cellpadding="0" cellspacing="0" border="0">
        <tr>
          <td colspan="4" align="center"><strong>Second Semester</strong></td>
        </tr>
        <tr>
          <td width="20%"><strong>SUBJECT</strong></td>
          <td width="40%"><strong>DESCRIPTION</strong></td>
          <td width="18%"><strong>UNITS</strong></td>
          <td width="22%"><strong>GRADE</strong></td>
        </tr>
        <%for(; i< vRetResult.size();){//1st semester only.
		iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
		if(iCurSem != 2)
			break;
		dTotalUnit += Double.parseDouble((String)vRetResult.elementAt(i + 10));
		strTemp = WI.getStrValue(vRetResult.elementAt(i+14));
		if(strTemp.length() == 0) {
			int iIndexOf = vInProgress.indexOf(vRetResult.elementAt(i + 3));
			if(iIndexOf > -1) {
				strTemp = "IP";
			}
		}
		%>
        <tr>
          <td><%=(String)vRetResult.elementAt(i+4)%></td>
          <td><%=(String)vRetResult.elementAt(i+5)%></td>
          <td><%=(String)vRetResult.elementAt(i+10)%></td>
          <td><%=strTemp%></td>
        </tr>
        <%i += 16;}//prints only 1st semester. - Inner for loop%>
        <tr>
          <td>&nbsp;</td>
          <td><div align="right"><strong>TOTAL&nbsp;&nbsp;&nbsp;&nbsp;</strong></div></td>
          <td><strong><%=dTotalUnit%></strong></td>
          <td>&nbsp;</td>
        </tr>
      </table>
      <%}//only for 1st year.%> </td>
  </tr>
  <%
iCurSem = 1;dTotalUnit = 0d;
if(i< vRetResult.size())
	iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
if(iCurSem == 0) {%>
  <tr>
    <td colspan="2" align="center"> <table width="90%" cellpadding="0" cellspacing="0" border="0">
        <tr>
          <td colspan="4" align="center"><strong>SUMMER</strong></td>
        </tr>
        <tr>
          <td><strong>SUBJECT</strong></td>
          <td><strong>DESCRIPTION</strong></td>
          <td><strong>UNITS</strong></td>
          <td><strong>GRADE</strong></td>
        </tr>
        <%for(; i< vRetResult.size();){//1st semester only.
		iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
		if(iCurSem != 0)
			break;
		dTotalUnit += Double.parseDouble((String)vRetResult.elementAt(i + 10));
		strTemp = WI.getStrValue(vRetResult.elementAt(i+14));
		if(strTemp.length() == 0) {
			int iIndexOf = vInProgress.indexOf(vRetResult.elementAt(i + 3));
			if(iIndexOf > -1) {
				strTemp = "IP";
			}
		}
		%>
        <tr>
          <td><%=(String)vRetResult.elementAt(i+4)%></td>
          <td><%=(String)vRetResult.elementAt(i+5)%></td>
          <td><%=(String)vRetResult.elementAt(i+10)%></td>
          <td><%=strTemp%></td>
        </tr>
        <%i += 16;}//prints only 1st semester. - Inner for loop%>
        <tr>
          <td align="center">&nbsp;</td>
          <td><div align="right"><strong>TOTAL&nbsp;&nbsp;&nbsp;&nbsp;</strong></div></td>
          <td><div align="left"><strong><%=dTotalUnit%></strong></div></td>
          <td>&nbsp;</td>
        </tr>
      </table></td>
  </tr>
  <%}//end of display summer.

}//end of for loop to display grade/course evaluation
%>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<%}%><br>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <td width="61%">Prepared by : <%=(CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1))%><br>
      Date and time printed : <%=WI.getTodaysDateTime()%> </td>
    <td width="39%"><div align="center"><br>
        Evaluated By :</div></td>
  </tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <td width="30%"><input type="checkbox" name="checkbox" value="checkbox">
      Birth Certificate (NSO Copy)</td>
    <td width="20%"><input type="checkbox" name="checkbox2" value="checkbox">
      Form 137</td>
    <td width="33%"><input type="checkbox" name="checkbox3" value="checkbox">
      Transfer Of Credential</td>
    <td width="17%"> <input type="checkbox" name="checkbox5" value="checkbox">
      Pictures</td>
  </tr>
  <tr>
    <td><input type="checkbox" name="checkbox4" value="checkbox">
      Good Moral</td>
    <td><input type="checkbox" name="checkbox22" value="checkbox">
      Form 138</td>
    <td><input type="checkbox" name="checkbox23" value="checkbox">
      Original TOR</td>
    <td>&nbsp;</td>
  </tr>
</table>
<%
dbOP.cleanUP();
if(strErrMsg == null) {//no error.%>
<script language="javascript">
window.print();

</script>
<%}%>
</body>
</html>
