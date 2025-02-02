<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
	try
	{
		dbOP = new DBOperation();
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
Vector vRetResult = null;
Vector vStudDetail= null;
String strAdmSlipNumber = null;
String strGrYearLevel = "";

ReportEnrollment reportEnrl= new ReportEnrollment();
vRetResult = reportEnrl.getStudentLoad(dbOP, request.getParameter("stud_id"),request.getParameter("sy_from"),
						request.getParameter("sy_to"),request.getParameter("offering_sem"));

if(vRetResult == null)
	strErrMsg = reportEnrl.getErrMsg();
else {
	vStudDetail = (Vector)vRetResult.remove(0);
	//get admission slip number here and as well save the information.
	strTemp = WI.fillTextValue("pmt_schedule");
	if(WI.fillTextValue("print_final").equals("1") && WI.fillTextValue("is_basic").length() > 0) 
		strTemp = "100";//pmt sch index = 250.
	//System.out.println(strTemp);
	strAdmSlipNumber = reportEnrl.autoGenAdmSlipNum(dbOP,
							(String)vStudDetail.elementAt(0),strTemp, 
                            WI.fillTextValue("sy_from"),WI.fillTextValue("offering_sem"));
	if(strAdmSlipNumber == null) 
		reportEnrl.getErrMsg();
}
String strExamSchName = null;
String strExamDate    = null;

strTemp = "select EXAM_SCHEDULE, exam_name from FA_PMT_SCHEDULE where pmt_sch_index = "+WI.fillTextValue("pmt_schedule");
try {
	if(WI.fillTextValue("pmt_schedule").length() > 0 && vStudDetail != null && vStudDetail.size() > 0) {
		java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
		if(rs.next()) {
			strExamSchName = rs.getString(2);
			strExamDate    = ConversionTable.convertMMDDYYYY(rs.getDate(1), true);
		}
		rs.close();
		//problem here, I have to search for if it is set per course.. 
		
		//1. Find if it is set per semester.. 
		strTemp = "select EXAM_SCHEDULE  from FA_PMT_SCHEDULE_EXTN where pmt_sch_index = "+WI.fillTextValue("pmt_schedule")+
			" and SY_FROM = "+WI.fillTextValue("sy_from")+" and semester="+WI.fillTextValue("offering_sem")+
			" and is_valid = 1";
		rs = dbOP.executeQuery(strTemp);
		if(rs.next())
			strExamDate    = ConversionTable.convertMMDDYYYY(rs.getDate(1), true);
		rs.close();

		//2. I have to find it now per course.
		 strTemp = "select EXAM_SCHEDULE  from FA_PMT_SCH_EXTN_COURSE where pmt_sch_index = "+WI.fillTextValue("pmt_schedule")+
			" and COURSE_INDEX = "+vStudDetail.elementAt(5)+" and semester="+WI.fillTextValue("offering_sem")+
			" and is_valid = 1";
		rs = dbOP.executeQuery(strTemp);
		if(rs.next())
			strExamDate    = ConversionTable.convertMMDDYYYY(rs.getDate(1), true);
		rs.close();
		
	}
}
catch(java.sql.SQLException sqlE) {}
		
String astrConvertTerm[] = {"Summer","1st Sem","2nd Sem","3rd Sem"};
boolean bolIsBasic = false;
if (WI.fillTextValue("is_basic").equals("1")) 
	bolIsBasic = true;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

if(strExamSchName != null) {
	strExamSchName = strExamSchName.toUpperCase();
	if(strSchCode.startsWith("AUF"))
		strExamSchName += "S";
}

boolean bolIsWUP = strSchCode.startsWith("WUP");
String strFontSize = "11px";
if(bolIsWUP)
	strFontSize = "9px";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
.style1 {
	font-size: 14px;
	font-weight: bold;
}

-->
</style>
<body onLoad="CloseWnd();" topmargin="10">
<%
if(strErrMsg != null){dbOP.cleanUP();
%>
<table border="0">
    <tr>
      <td width="100%"><div align="center"><font size="3"><%=strErrMsg%></font></div></td>
    </tr>
</table>
 <%return;}%>
<div id="Layer2" style="position:absolute; left:6px; top:24px; width:48px; height:58px; z-index:3"><img src="permit.jpg" height="54" width="45"></div>
<div id="Layer1" style="position:absolute; left:272px; top:30px; width:98px; height:34px; z-index:2; visibility: visible; overflow: visible; background-color: #CCCCCC; layer-background-color: #CCCCCC; border: 1px none #000000;" class="thinborder">
  
  <table width="95" height="27" border="1" class="thinborder">
  	<tr>
		<td><p align="justify" class="thinborder" style="font-size:6px;">
		UPHS-J1-FIN-EOP-11<br> 
  		12-11-2012
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;01</p></td>
	</tr>
  </table>
</div>
<table width="45%" border="0" cellpadding="0" cellspacing="0">
  
  
  <tr valign="top">
    <td height="21" align="center" style="font-size:8px; font-weight:bold">
	<%if(strSchCode.startsWith("PIT")){%><font style="font-size:8px;"><%}%>
		<%if(strSchCode.startsWith("PIT")){%>
		PALOMPON INSTITUTE OF TECHNOLOGY<BR>
		PALOMPON, LEYTE<BR>
		<%}if(!strSchCode.startsWith("UPH") && !strSchCode.startsWith("WUP")){%>	
		EXAMINATION PERMIT 
		<%}%>
		<%if(strSchCode.startsWith("PIT")){%></font><%}%>
	<%if(strSchCode.startsWith("UPH")){%>
		<font style="font-size:11px;">
		<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font> <br>
          <font size="1"><%=WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,false,false), "", "<br>", "&nbsp;")%>
          <%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false), "", "<br>", "&nbsp;")%>
          <%=WI.getStrValue(SchoolInformation.getAddressLine3(dbOP,false,false), "", "<br>", "&nbsp;")%></font>
		<%=strExamSchName.toUpperCase()%> EXAMINATION PERMIT
	<%}%>
	<%if(strSchCode.startsWith("WUP")){%>
		<%=strExamSchName.toUpperCase()%> EXAMINATION PERMIT
	<%}%>
	</td>
  </tr>
<%if(!strSchCode.startsWith("UPH") && !strSchCode.startsWith("WUP")){%>
  <tr valign="top"> 
    <td height="18" align="center" style="font-size:9px; font-weight:bold">
	<%if(strSchCode.startsWith("PIT")){%><font style="font-size:9px;"><%}%>
		<u><%=strExamSchName%></u>
	<%if(strSchCode.startsWith("PIT")){%></font><%}%>
	</td>
  </tr>
<%}%>
<!--
  <tr valign="top">
    <td height="21" colspan="2" align="center" style="font-size:15px; font-weight:bold">&nbsp;</td>
  </tr>
-->
  <tr valign="top">
    <td height="18" align="center" valign="bottom" style="font-size:9px ">&nbsp;
	<%if(!bolIsBasic){%><%=astrConvertTerm[Integer.parseInt(request.getParameter("offering_sem"))]%>/<%}%>Academic Year <%=request.getParameter("sy_from")%> -<%=request.getParameter("sy_to")%> </td>
  </tr>
  <tr valign="top">
    <td height="18" align="right" valign="bottom" style="font-size:9px ">Permit No : 
	<%if(strSchCode.startsWith("WUP")){%><font style="font-size:11px;"><%}%>
	<%=strAdmSlipNumber%><%if(strSchCode.startsWith("WUP")){%></font><%}%> &nbsp;&nbsp;&nbsp;</td>
  </tr>
  <tr valign="top">
    <td valign="bottom" style="font-size:9px; font-weight:bold">
	<%if(strSchCode.startsWith("PIT")){%><font style="font-size:11px;"><%}%>
	Student Number  : <u><%=request.getParameter("stud_id")%></u>
	<%if(strSchCode.startsWith("PIT")){%> </font><%}%>
	</td>
  </tr>
  <tr valign="top">
    <td valign="bottom" style="font-size:10px; font-weight:bold">
	<%if(strSchCode.startsWith("PIT")){%><font style="font-size:11px;"><%}%>
		Name : <u><%=((String)vStudDetail.elementAt(2)).toUpperCase()%></u>
	<%if(strSchCode.startsWith("PIT")){%> </font><%}%>
	</td>
  </tr>
<%if(bolIsBasic){
//I have to find section.
strTemp = "select section,count(*) as count_ from e_sub_section  join enrl_final_cur_list on (e_sub_section.sub_sec_index = enrl_final_cur_list.sub_sec_index) "+
		"where enrl_final_cur_list.is_valid = 1 and user_index = "+(String)vStudDetail.elementAt(0)+
  		" and enrl_final_cur_list.sy_from = "+WI.fillTextValue("sy_from")+" and current_semester = 1 group by section order by count_ desc";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp == null)
	strTemp = "";
%>
    <tr>
      <td height="18" style="font-size:9px ">Gr./Yr & Section: <u><%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudDetail.elementAt(4)), false)%> - <%=strTemp%></u></td>
    </tr>
<%}else{%>
  <tr valign="top">
    <td height="18" style="font-size:9px ">Course : <%=(String)vStudDetail.elementAt(3)%> <%=WI.getStrValue((String)vStudDetail.elementAt(4), " - ", "","")%></td>
  </tr>
  <tr>
    <td height="18" valign="bottom" style="font-size:9px ">Date of Exams : <u><%=strExamDate%></u>	</td>
  </tr>
<%}%>
<%if(!bolIsWUP){%>
  
<%}%>
</table>
<% String subjcode="";%>
<table width="45%" border="0" cellspacing="0" cellpadding="0" class="thinborder" >
  <tr>
    <td width="31%" align="center" class="thinborder" style="font-size:9px "><span class="style1" style="font-size:9px ">SUBJECT</span></td>
    <td width="69%" height="10" align="center" class="thinborder"><span class="style1" style="font-size:9px ">
      <%if(bolIsBasic){%>
      TEACHER'S SIGNATURE
      <%}else{%>
PROCTOR'S SIGNATURE
       <%}%>
    </span></td>
  </tr>
	<%int iRowsPrinted = 0;
	while(vRetResult.size() > 0) {%>
	  <tr>
		<td height="19" class="thinborder" style="font-size:8px "><%if(vRetResult.size() > 0){%>
          <%=(String)vRetResult.elementAt(0)%>
          <%subjcode=(String)vRetResult.elementAt(0);%>
          <%for(int i =0; i < 11; ++i) vRetResult.removeElementAt(0);}else{%>
&nbsp;
<%}%></td>
		<td class="thinborder">&nbsp;</td>
	  </tr>
	<%}//for(; iRowsPrinted < 12; ++iRowsPrinted){%>
	<%//}%>
</table>
<%if(!bolIsWUP){%>
	<table width="97%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td colspan="2" valign="bottom" style="font-weight:bold">&nbsp;</td>
	  </tr>
	  <tr>
		<td valign="bottom" style="font-size:9px "><br><u><%=(String)request.getSession(false).getAttribute("first_name")%></u>&nbsp;</td>
		<td valign="bottom">__________________&nbsp;</td>
	  </tr>
	  <tr>
		<td width="18%" valign="bottom" style="font-size:7px ">Prepared By </td>
		<td width="82%" valign="bottom" style="font-size:7px ">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Approved By </td>
	  </tr>
	<%if(strSchCode.startsWith("AUF")){%>
	  <tr>
		<td valign="bottom">&nbsp;</td>
		<td valign="bottom">&nbsp;</td>
	  </tr>
	  <tr>
		<td colspan="2" valign="bottom"><span style="font-weight:bold; font-size:9px">Note : Any erasure will invalidate this permit</span></td>
	  </tr>
	  <tr>
		<td valign="bottom" height="25" style="font-size:9px ">AUF-FORM-AFO-16<%if(bolIsBasic){%>.1<%}%></td>
		<td valign="bottom">&nbsp;</td>
	  </tr>
	  <tr>
		<td valign="bottom" height="18" style="font-size:9px "><%if(bolIsBasic){%>February 1, 2009- Rev. 01<%}else{%>Nov. 13, 2008-Rev.01<%}%> </td>
		<td valign="bottom">&nbsp;</td>
	  </tr>
	<%}%>
</table>
<%}%>



<script src="../../../jscript/common.js"></script>
<script language="JavaScript">
//get this from common.js
this.autoPrint();

this.closeWnd = 1;
</script>

</body>
</html>
<%
dbOP.cleanUP();
%>

<%!
public String faculty_name(String subcode)
{ 
    String fname="";
	java.sql.Connection con;
	java.sql.Statement s;
	java.sql.ResultSet rs;
	java.sql.PreparedStatement pst;
	
	String url= "jdbc:jtds:sqlserver://JONELTA_SERVER/UPH05_SA";
	String id= "sa";
	String pass = "174tned389nabADMIN";

	con=null;
	s=null;
	pst=null;
	rs=null;
	
	try {
	Class.forName("net.sourceforge.jtds.jdbc.Driver");					
	con = java.sql.DriverManager.getConnection(url, id, pass);	
    s = con.createStatement();
	String sql="select top 1 faculty_name from faculty_eval where subjcode like '"+subcode+"'";
	rs = s.executeQuery(sql);
	rs.next();
	fname=rs.getString("faculty_name");
	 } catch (Exception e) {}
	
	
	try {
	//close database, tables,ans recordset
	if(rs!=null) rs.close();
	if(s!=null) s.close();
	if(con!=null) con.close();   
	 } catch (Exception e) {fname="none";}
	if (fname.trim()=="") {
	return "------";}
	else {	
	 return fname;}	 
}
%>