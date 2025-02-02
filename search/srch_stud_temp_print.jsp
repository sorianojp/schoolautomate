<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PrintPg() {
	document.search_util.print_pg.value = "1";
	document.search_util.invalidate_id.value = "";
	document.search_util.submit();	
}
function ReloadPage()
{
	document.search_util.searchStudent.value = "";
	document.search_util.print_pg.value = "";
	document.search_util.invalidate_id.value = "";
	document.search_util.submit();
}
function SearchStudent()
{
	document.search_util.searchStudent.value = "1";
	document.search_util.print_pg.value = "";
	document.search_util.invalidate_id.value = "";
	document.search_util.submit();
}
function ViewDetail(strStudID)
{
//popup window here. 
	var pgLoc = "./stud_info_view.jsp?stud_id="+escape(strStudID);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SetSelectValue(strStudID)
{
	document.search_util.selectValue.value = strStudID;
}
function DisplaySYTo() {
	var strSYFrom = document.search_util.sy_from.value;
	if(strSYFrom.length == 4)
		document.search_util.sy_to.value = eval(strSYFrom) + 1;
	if(strSYFrom.length < 4)
		document.search_util.sy_to.value = "";
}
function ShowAdvisedSubject(strEnrolStat, strStudID) {
	var pgLoc;
	if(strEnrolStat == 1) {//old stud
		pgLoc = "../ADMIN_STAFF/enrollment/reports/student_sched.jsp?stud_id="+escape(strStudID);
	}
	else {//not validated.
		pgLoc = "../ADMIN_STAFF/enrollment/advising/gen_advised_schedule_print.jsp?print=0&stud_id="+escape(strStudID);
	}
	var win=window.open(pgLoc,"ViewWindow",'width=800,height=500,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function InvalidateAdvising(strStudID) {
	var vProceed = confirm("Are you sure you want to remove advising information.");
	if(vProceed) {
		document.search_util.invalidate_id.value = strStudID;
		document.search_util.submit();
	}
}
</script>

<body>
<%@ page language="java" import="utility.*,search.SearchStudent,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-SEARCH-Students","srch_stud_temp.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

//Invalidate a temp student's enrollment if it is called.
if(WI.fillTextValue("invalidate_id").length() > 0) {
	enrollment.NAApplicationForm naApplForm = new enrollment.NAApplicationForm();
	if(!naApplForm.invalidateAdvising(dbOP, WI.fillTextValue("invalidate_id"),
	 	(String)request.getSession(false).getAttribute("userId"), 
		(String)request.getSession(false).getAttribute("login_log_index")) )
		strErrMsg = naApplForm.getErrMsg();
}

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=",">","<"};
String[] astrSortByName    = {"Student ID","Lastname","Firstname","Gender","Course","Enrol. Date"};
String[] astrSortByVal     = {"temp_id","lname","fname","gender","course_name","new_application.create_date"};


int iSearchResult = 0;
String[] astrConvertPmt = {"","One Pmt","Two Pmt","","",""};
SearchStudent searchStud = new SearchStudent(request);
if(WI.fillTextValue("searchStudent").compareTo("1") == 0){
	vRetResult = searchStud.searchTempStudent(dbOP);
	if(vRetResult == null)
		strErrMsg = searchStud.getErrMsg();
	else	
		iSearchResult = searchStud.getSearchCount();
}

Vector vConAddress = new Vector();
boolean bolShowConAddr = false;
int iIndexOf = 0;
if(WI.fillTextValue("show_con_addr").length() > 0 && WI.fillTextValue("sy_from").length() > 0 && iSearchResult > 0) {
	bolShowConAddr = true;
	
	java.sql.ResultSet rs = dbOP.executeQuery("select new_application.application_index, CON_PER_NAME, CON_HOUSE_No, con_city, con_zip, con_tel, CON_EMAIL from na_other_info join new_application on (new_application.application_index = "+
						"na_other_info.APPLICATION_INDEX) where is_valid = 1 and SCHYR_FROM ="+WI.fillTextValue("sy_from"));
	strTemp = null;
	while(rs.next()) {
		vConAddress.addElement(rs.getString(1));
		
		strTemp = null;
		if(rs.getString(3) != null) {//CON_HOUSE_No	must have entry.. 
			strTemp = rs.getString(2);//CON_PER_NAME
			if(strTemp == null) 
				strTemp = rs.getString(3);//CON_HOUSE_No
			else	
				strTemp = strTemp +"<br>"+rs.getString(3);//CON_HOUSE_No
			if(rs.getString(4) != null) //con_city
				strTemp = strTemp +", "+rs.getString(4);//con_city			
			if(rs.getString(5) != null) //con_zip
				strTemp = strTemp +" - "+rs.getString(5);//con_zip			
			if(rs.getString(6) != null) //con_tel
				strTemp = strTemp +"<br>Tel: "+rs.getString(6);//con_tel			
			if(rs.getString(7) != null) //CON_EMAIL
				strTemp = strTemp +"<br>Email: "+rs.getString(7);//CON_EMAIL			
		}
		vConAddress.addElement(strTemp);
	}
	rs.close();
}

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#CCCCCC"><div align="center"><strong>:::: 
          TEMPORARY STUDENT SEARCH RESULT PAGE ::::</strong></div></td>
    </tr>
</table>

<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
  <td width="5%" height="35">&nbsp;</td>
      
    <td><strong><font size="3">Total Result Found : <%=iSearchResult%></font></strong></td>
  </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="15%" height="25" ><div align="center"><strong><font size="1">STUDENT 
          ID</font></strong></div></td>
      <td width="13%"><div align="center"><strong><font size="1">START DATE OF 
          ENROLLMENT </font></strong></div></td>
      <td width="18%"><div align="center"><strong><font size="1">LNAME, FNAME, 
          MI </font></strong></div></td>
      <td width="4%"><div align="center"><strong><font size="1">GEN</font></strong></div></td>
      <td width="35%"><div align="center"><strong><font size="1">COURSE/MAJOR</font></strong></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>APPL CATG</strong></font></div></td>
      <td width="5%"><div align="center"><strong><font size="1"> ENROLLED</font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1"> ADVISED</font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">NO. OF PMT</font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">Contact Address</font></strong></div></td>
    </tr>
    <%
for(int i=0; i<vRetResult.size(); i+=14){%>
    <tr> 
      <td height="25"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td height="25"><font size="1"><%=(String)vRetResult.elementAt(i+13)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+2)%>, <%=(String)vRetResult.elementAt(i+3)%> 
        <%if(vRetResult.elementAt(i+4) != null && ((String)vRetResult.elementAt(i+4)).length() > 0){%>
        , <%=((String)vRetResult.elementAt(i+4)).charAt(0)%> 
        <%}%>
        </font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+5),"n/f")%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+6)%> 
        <%
	  if(vRetResult.elementAt(i+7) != null){%>
        /<%=(String)vRetResult.elementAt(i+7)%> 
        <%}%>
        </font></td>
      <td align="center"><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></td>
      <td align="center"> <%=WI.getStrValue((String)vRetResult.elementAt(i + 10),"&nbsp;")%></td>
      <td align="center">&nbsp; <%if( Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+11),"0")) > 0){%> <img src="../images/tick.gif"> <%}%> </td>
      <td>&nbsp; <%=astrConvertPmt[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+12),"0"))]%> </td>
      <%if(bolShowConAddr) {
	  	strTemp = null;
		iIndexOf = vConAddress.indexOf(vRetResult.elementAt(i));
		if(iIndexOf > -1) 
			strTemp = (String)vConAddress.elementAt(iIndexOf + 1);
	  %>
	  	<td><font size="1"><%=WI.getStrValue(strTemp, "&nbsp;")%></font></td>
	  <%}%>
    </tr>
    <%}%>
  </table>
<script language="javascript">
window.print();
</script>

<%}//vRetResult is not null
%>
</body>
</html>
<%
dbOP.cleanUP();
%>