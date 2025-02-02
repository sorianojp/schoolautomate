<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="window.print();">
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
	if(!naApplForm.invalidateAdvising(dbOP, false, WI.fillTextValue("invalidate_id"),
	 	(String)request.getSession(false).getAttribute("userId"), 
		(String)request.getSession(false).getAttribute("login_log_index"),WI.fillTextValue("sy_from"), 
		WI.fillTextValue("sy_to"), WI.fillTextValue("semester")) )
		strErrMsg = naApplForm.getErrMsg();
}

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=",">","<"};
String[] astrSortByName    = {"Student ID","Lastname","Firstname","Gender","Course","Enrol. Date"};
String[] astrSortByVal     = {"temp_id","lname","fname","gender","course_name","new_application.create_date"};


int iSearchResult = 0;
String[] astrConvertPmt = {"","One Pmt","Two Pmt","more than two","more than two","more than two","more than two","more than two",
							"more than two","more than two","more than two","more than two","more than two","more than two",
							"more than two","more than two","more than two","more than two","more than two","more than two"};//upto 19
SearchStudent searchStud = new SearchStudent(request);
if(WI.fillTextValue("searchStudent").compareTo("1") == 0){
	vRetResult = searchStud.searchOldStudEnrollment(dbOP);
	if(vRetResult == null)
		strErrMsg = searchStud.getErrMsg();
	else	
		iSearchResult = searchStud.getSearchCount();
}

boolean bolRemoveHeader = false;
if(WI.fillTextValue("no_header").length() > 0) 
	bolRemoveHeader = true;

boolean bolShowEnrolledDateTime = false;
if(WI.fillTextValue("show_datetime").length() > 0 && WI.fillTextValue("is_enrolled").length() > 0)
	bolShowEnrolledDateTime = true;


Vector vConAddress = new Vector();
boolean bolShowConAddr = false;
int iIndexOf = 0;
if(WI.fillTextValue("show_con_addr").length() > 0 && WI.fillTextValue("sy_from").length() > 0 && iSearchResult > 0) {
	bolShowConAddr = true;
	
	java.sql.ResultSet rs = dbOP.executeQuery("select na_old_stud.user_index, CON_PER_NAME, CON_HOUSE_No, con_city, con_zip, con_tel, CON_EMAIL from info_contact "+
							"join na_old_stud on (na_old_stud.user_index = info_contact.user_index) where is_valid = 1 and sy_from = "+
							WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester"));
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


if(vRetResult != null && vRetResult.size() > 0){
if(!bolRemoveHeader) {%>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr> 
		<td height="25" colspan="3" bgcolor="#cccccc"><div align="center"><strong> 
			SEARCH RESULT</strong></div></td>
	  </tr>
	  <tr> 
		<td width="66%" height="25"><b> Total Students : <%=iSearchResult%> </b></td>
		  <td width="34%"> <div align="right"> </div></td>
	  </tr>
	</table>
<%}%>
  
<table  bgcolor="#FFFFFF" width="100%" <%if(!bolRemoveHeader) {%>border="1"<%}%> cellspacing="0" cellpadding="0">
  <tr style="font-weight:bold" align="center"> 
    <td  width="15%" height="25" ><font size="1">STUDENT ID</font></td>
<%if(!bolShowEnrolledDateTime) {%>
      <td width="13%"><font size="1">START DATE OF ENROLLMENT </font></td>
<%}else{%>
      <td width="13%"><font size="1">DATE AND TIME ENROLLED</font></td>
<%}%>
    <td width="18%"><font size="1">LNAME, FNAME, MI </font></td>
    <td width="4%"><font size="1">GEN</font></td>
    <td width="35%"><font size="1">COURSE/MAJOR</font></td>
    <td width="5%"><font size="1">Year Level</font></td>
    <td width="5%"><font size="1">APPL CATG</font></td>
    <td width="5%"><font size="1"> ADVISED</font></td>
    <td width="5%"><font size="1">NO. OF PMT</font></td>
<%if(bolShowConAddr) {%>
    <td width="5%"><font size="1">Current Address</font></td>
<%}%>
  </tr>
  <%
	boolean bolIsEnrolled = false;
for(int i=0; i<vRetResult.size(); i+=14){bolIsEnrolled = false;%>
  <tr> 
    <td height="25"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
<%if(!bolShowEnrolledDateTime) {%>
      <td height="25"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+12),"Not thru' system").substring(0,11)%></font></td>
<%}else{
strTemp = (String)vRetResult.elementAt(i+12);
if(strTemp.endsWith("E12")) {
	strTemp = strTemp.substring(0, strTemp.length() - 3);
	strTemp = ConversionTable.replaceString(strTemp, ".","");
	//System.out.println(strTemp+": "+vRetResult.elementAt(i+12));
	while(strTemp.length() < 13)
		strTemp = strTemp + "0";
}
%>
      <td><font size="1"><%=WI.formatDateTime(Long.parseLong(strTemp),5)%></font></td>
<%}%>
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
    <td align="center"><font size="1"><%=WI.getStrValue(vRetResult.elementAt(i+13), "N/A")%></font></td>
    <td align="center"><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></td>
    <!--      <td align="center">&nbsp;
        <%if( Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+10),"0")) > 0 && 
			vRetResult.elementAt(i+12) != null){%>
        <img src="../images/tick.gif"> 
        <%bolIsEnrolled = true;}%>
      </td>-->
    <td align="center">&nbsp; <%if( Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+10),"0")) > 0){%> <img src="../images/tick.gif"> <%}%> </td>
    <td>&nbsp; <%//=astrConvertPmt[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+11),"0"))]%><%=WI.getStrValue(vRetResult.elementAt(i+11),"0")%> </td>
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

<%}//vRetResult is not null
%>

</body>
</html>
<%
dbOP.cleanUP();
%>