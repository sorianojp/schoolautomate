<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/td.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	this.SubmitOnce('formstep2');
}
function CopySourceOfIncome() {
	document.formstep2.SOURCE_OF_INCOME.value = 
		document.formstep2.SOURCE_OF_INCOME_SELECT[document.formstep2.SOURCE_OF_INCOME_SELECT.selectedIndex].text;
}
function  ShowHideDetail() {
	//strShow = 1 , show the table rows. else hide the table rows.
	var strShow = 0;
	if(document.formstep2.stud_employed[0].checked)
		strShow = 1;
	else
		strShow = 0;
	if(strShow == 1) {
		this.showLayer('tr_1');
		this.showLayer('tr_2');
		this.showLayer('tr_3');
		this.showLayer('tr_4');
		this.showLayer('tr_5');
		this.showLayer('tr_6');
		this.showLayer('tr_7');
		this.showLayer('tr_8');
	}
	else {
		this.hideLayer('tr_1');
		this.hideLayer('tr_2');
		this.hideLayer('tr_3');
		this.hideLayer('tr_4');
		this.hideLayer('tr_5');
		this.hideLayer('tr_6');
		this.hideLayer('tr_7');
		this.hideLayer('tr_8');
	}
}
</script>
<body bgcolor="#FFFFFF">
<%@ page language="java" import="utility.*,java.util.Vector,enrollment.PersonalInfoManagement,java.util.StringTokenizer" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	Vector[] vEditInfo = null;
	Vector vRetResult = null;
	Vector vRecruit = null;
	String strImgFileExt = null;

	String[] astrConvertYr = {"","1st","2nd","3rd","4th","5th","6th"};
	String[] astrConvertSem= {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Student Info Mgmt","stud_personal_info_page2.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
								
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> Error in opening connection</font></p>
<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission","Student Info Mgmt",request.getRemoteAddr(),
														"stud_personal_info_print.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0 )//NOT AUTHORIZED.
{
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs","Student Tracker",request.getRemoteAddr(),
														"stud_personal_info_print.jsp");
	if(iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Guidance & Counseling","Student Tracker",request.getRemoteAddr(),
														"stud_personal_info_print.jsp");
		if(comUtil.IsAuthorizedModule(dbOP,(String)request.getSession(false).getAttribute("userId"),"Student Affairs"))
			iAccessLevel = 2;//allow edit.
	}
	if(iAccessLevel ==0) {
		dbOP.cleanUP();
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
}

//end of authenticaion code.

strTemp = request.getParameter("stud_id");

if(strTemp.length() > 0){
	if(dbOP.mapUIDToUIndex(strTemp) == null) {
		dbOP.cleanUP();
		request.getSession(false).setAttribute("tempId",request.getParameter("stud_id"));
		response.sendRedirect(response.encodeURL("../../PARENTS_STUDENTS/ADMISSION MODULE PAGES/single file items/ADMISSION FOR NEW_TRANSFERRE STUDENTS/gspis_print.jsp"));
		return;
	}
}



PersonalInfoManagement pInfo = new PersonalInfoManagement();
String strSchoolName = "select school_name from SYS_INFO";
strSchoolName = dbOP.getResultOfAQuery(strSchoolName, 0);

//edit only if it is submitted.

	vRecruit = pInfo.getStudentRecruitDetails(dbOP,strTemp, false);	
	vEditInfo = pInfo.viewPermStudPersonalInfo(dbOP,strTemp);			
	if(vEditInfo == null)
		strErrMsg = pInfo.getErrMsg();		

//	System.out.println("strErrMsg : " + strErrMsg);


String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");

String[] strCount = {"I A","I B","II","III","IV","V","VI","VII","VIII","IX","X"};
String[] strIncome = {"P 1,000 - P 5,000","P 5,000 - P 10,000","P 10,000 - P 15,000","P 15,000 - P 20,000","P 20,000 - P 25,000","P 25,000 and above"};
int iCount = 0;
int j=0;

boolean bShowForData = false;
if (vEditInfo!=null && vEditInfo[0].elementAt(28)!=null && ((String)vEditInfo[0].elementAt(28)).length()>0)
	bShowForData = true;

if (!bShowForData && vEditInfo!=null)
{
	if (dbOP.mapOneToOther("na_foreign_stud_list","stud_index",(String)vEditInfo[0].elementAt(10),"stud_index","")!=null)
		bShowForData = true;
}

%>
<form name="formstep2" action="./stud_personal_info_print.jsp" method="post">
  <% if(strErrMsg != null)
{%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="10" colspan="3">&nbsp; <b><%=strErrMsg%></b></td>
    </tr>
  </table>
  <% dbOP.cleanUP();
	return;
} 
   if (vEditInfo!= null) {
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <%

  if(strSchoolCode != null && strSchoolCode.startsWith("LNU") ){%>
    <tr bgcolor="#DDDDDD">
      <td height="20" colspan="3" align="center"><strong>::::
        STUDENT'S GENERAL INFORMATION (SGI) ::::</strong></td>
    </tr>
    <%}else{%>
    <tr bgcolor="#DDDDDD">
      <td height="20" colspan="3" align="center"><strong>::::
        GENERAL STUDENT PERSONAL INFORMATION SHEET (GSPIS) ::::</strong></td>
    </tr>
    <%} %>
    <tr>
      <td colspan="3" height="10">&nbsp;</td>
    </tr>
    <tr>
      <td width="22%" height="23">&nbsp; COURSE </td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(0))%></td>
      <td rowspan="5" align="center"><%
      strTemp = WI.fillTextValue("stud_id");
      strTemp = "<img src=\"../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=125 height=125 align=\"center\" border=\"1\">";%>
        <%=WI.getStrValue(strTemp)%>&nbsp;</td>
    </tr>
    <tr>
      <td width="22%" height="23">&nbsp; MAJOR </td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(2))%></td>
    </tr>
    <tr>
      <td height="25">&nbsp; CURRICULUM YEAR</td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(4))%> to <%=WI.getStrValue(vEditInfo[0].elementAt(5))%></td>
    </tr>
    <tr>
      <td height="25">&nbsp; YEAR LEVEL/TERM</td>
      <td><% if(vEditInfo[0].elementAt(8) != null){%>
        <%=astrConvertYr[Integer.parseInt(((String)vEditInfo[0].elementAt(8)))]%>
        <%}else{%>
        N/A
        <%}%>
        / <%=astrConvertSem[Integer.parseInt(((String)vEditInfo[0].elementAt(9)))]%></td>
    </tr>
    <tr>
      <td>&nbsp; SCHOOL YEAR</td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(6))%> to <%=WI.getStrValue(vEditInfo[0].elementAt(7))%></td>
    </tr>
    <tr>
      <td colspan="3" height="10">&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDDD">
      <td height="20" colspan="3"><strong><font size="2">&nbsp; <%=strCount[iCount++]%> &#8211; PERSONAL DATA</font></strong></td>
    </tr>
    <tr>
      <td width="34%" height="20" valign="bottom">&nbsp; Last Name </td>
      <td width="32%" valign="bottom">First Name </td>
      <td width="34%" valign="bottom">Middle Name </td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=(String)vEditInfo[0].elementAt(13)%></td>
      <td><%=(String)vEditInfo[0].elementAt(11)%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(12))%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Gender </td>
      <td height="15" valign="bottom">Religion </td>
      <td height="15" valign="bottom">Nationality</td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(15),"xxxxx")%></td>
      <td height="25">&nbsp;<%=WI.getStrValue(vEditInfo[0].elementAt(16),"xxxxx")%></td>
      <td height="25">&nbsp;<%=WI.getStrValue(vEditInfo[0].elementAt(17),"xxxxx")%></td>
    </tr>
    <tr valign="bottom">
      <td height="20">&nbsp; Date of Birth<font size="1">(mm/dd/yyyy)</font></td>
      <td height="20">Place of Birth </td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <%
StringTokenizer strToken = new StringTokenizer(WI.getStrValue(vEditInfo[0].elementAt(18)), "/");
String strMM = "";
String strDD = "";
String strYYYY = "";
if(strToken.hasMoreElements())
	strMM =(String)strToken.nextElement();
if(strToken.hasMoreElements())
	strDD =(String)strToken.nextElement();
if(strToken.hasMoreElements())
	strYYYY =(String)strToken.nextElement();

%>
      <td height="25">&nbsp;
        <%if (WI.getStrValue(vEditInfo[0].elementAt(18)).length()>0){%>
        <%=strMM%>/<%=strDD%>/<%=strYYYY%>
        <%} else {%>
        xxxxx
        <%}%></td>
      <td height="25"><%=WI.getStrValue(vEditInfo[0].elementAt(19),"xxxxx")%></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr valign="bottom">
      <td height="25">&nbsp; Civil Status </td>
      <td height="25"><%if(WI.getStrValue(vEditInfo[0].elementAt(15),"").equals("F") && vEditInfo[0].elementAt(21)!=null){%>
        Maiden's Name
        <%} else if (WI.getStrValue(vEditInfo[0].elementAt(15),"").equals("M") && vEditInfo[0].elementAt(22)!=null) {%>
        Name of Spouse
        <%} else {%>
        &nbsp;
        <%}%></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(20),"xxxxx")%></td>
      <td height="25"><%if (WI.getStrValue(vEditInfo[0].elementAt(15),"").equals("F")){%>
        <%=WI.getStrValue(vEditInfo[0].elementAt(21))%>
        <%} else {%>
        <%=WI.getStrValue(vEditInfo[0].elementAt(22))%>
        <%}%></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;
        <%if (vEditInfo[0].elementAt(23) != null){%>
        No. of children :<%=WI.getStrValue(vEditInfo[0].elementAt(23))%>
        <%} else {%>
        &nbsp;
        <%}%></td>
      <td  colspan="2" height="25">Email Address: <%=WI.getStrValue(vEditInfo[0].elementAt(24),"xxxxx")%></td>
      <%if(vEditInfo[0].elementAt(87)!=null){%>
    <tr>
      <td height="25">&nbsp; Birth Order &nbsp;&nbsp;&nbsp;&nbsp; :<%=WI.getStrValue(vEditInfo[0].elementAt(87))%> </td>
      <td  colspan="2" height="25">&nbsp;</td>
    </tr>
    <%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDDD">
      <td height="20" colspan="3"><strong><font size="2">&nbsp; <%=strCount[iCount++]%> &#8211; ALIEN STATUS DATA (for alien/foreigner student only)</font></strong></td>
    </tr>
    <%if (bShowForData){%>
    <tr>
      <td width="34%" height="20" valign="bottom">&nbsp; Visa Status</td>
      <td width="32%" valign="bottom">Authorized Stay</td>
      <td width="34%" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(26),"xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(27),"xxxxx")%></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Passport No.</td>
      <td height="15" valign="bottom">Place of Issue</td>
      <td valign="bottom">Expiration Date <font size="1">(mm/dd/yyyy)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(28),"xxxxx")%></td>
      <td height="25"><%=WI.getStrValue(vEditInfo[0].elementAt(29),"xxxxx")%></td>
      <td><%if (WI.getStrValue(vEditInfo[0].elementAt(30)).length()>0){
strToken = new StringTokenizer(WI.getStrValue(vEditInfo[0].elementAt(30)), "/");
if(strToken.hasMoreElements())
	strMM =(String)strToken.nextElement();
else	strMM = "";
if(strToken.hasMoreElements())
	strDD =(String)strToken.nextElement();
else strDD = "";
if(strToken.hasMoreElements())
	strYYYY =(String)strToken.nextElement();
else strYYYY = "";

%>
        <%=strMM%>/<%=strDD%>/<%=strYYYY%>
        <%} else {%>
        xxxxx
        <%}%></td>
    </tr>
    <tr valign="bottom">
      <td height="20">&nbsp; ACR NO.</td>
      <td height="20">Date of Issue<font size="1">(mm/dd/yyyy)</font></td>
      <td>Expiration Date <font size="1">(mm/dd/yyyy)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(31),"xxxxx")%></td>
      <td height="25"><%if (WI.getStrValue(vEditInfo[0].elementAt(32)).length()>0){
strToken = new StringTokenizer(WI.getStrValue(vEditInfo[0].elementAt(32)), "/");
if(strToken.hasMoreElements())
	strMM =(String)strToken.nextElement();
else	strMM = "";
if(strToken.hasMoreElements())
	strDD =(String)strToken.nextElement();
else strDD = "";
if(strToken.hasMoreElements())
	strYYYY =(String)strToken.nextElement();
else strYYYY = "";
%>
        <%=strMM%>/<%=strDD%>/<%=strYYYY%>
        <%} else {%>
        xxxxx
        <%}%></td>
      <td><%if (WI.getStrValue(vEditInfo[0].elementAt(33)).length()>0){
strToken = new StringTokenizer(WI.getStrValue(vEditInfo[0].elementAt(33)), "/");
if(strToken.hasMoreElements())
	strMM =(String)strToken.nextElement();
else	strMM = "";
if(strToken.hasMoreElements())
	strDD =(String)strToken.nextElement();
else strDD = "";
if(strToken.hasMoreElements())
	strYYYY =(String)strToken.nextElement();
else strYYYY = "";
%>
        <%=strMM%>/<%=strDD%>/<%=strYYYY%>
        <%} else {%>
        xxxxx
        <%}%></td>
    </tr>
    <tr valign="bottom">
      <td height="25">&nbsp; CRTS NO.</td>
      <td height="25">Date of Issue<font size="1">(mm/dd/yyyy)</font></td>
      <td>Expiration Date <font size="1">(mm/dd/yyyy)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(34),"xxxxx")%></td>
      <td height="25"><%if (WI.getStrValue(vEditInfo[0].elementAt(35)).length()>0){
strToken = new StringTokenizer(WI.getStrValue(vEditInfo[0].elementAt(35)), "/");
if(strToken.hasMoreElements())
	strMM =(String)strToken.nextElement();
else	strMM = "";
if(strToken.hasMoreElements())
	strDD =(String)strToken.nextElement();
else strDD = "";
if(strToken.hasMoreElements())
	strYYYY =(String)strToken.nextElement();
else strYYYY = "";
%>
        <%=strMM%>/<%=strDD%>/<%=strYYYY%>
        <%} else {%>
        xxxxx
        <%}%></td>
      <td><%if (WI.getStrValue(vEditInfo[0].elementAt(36)).length()>0){
strToken = new StringTokenizer(WI.getStrValue(vEditInfo[0].elementAt(36)), "/");
if(strToken.hasMoreElements())
	strMM =(String)strToken.nextElement();
else	strMM = "";
if(strToken.hasMoreElements())
	strDD =(String)strToken.nextElement();
else strDD = "";
if(strToken.hasMoreElements())
	strYYYY =(String)strToken.nextElement();
else strYYYY = "";

%>
        <%=strMM%>/<%=strDD%>/<%=strYYYY%>
        <%} else {%>
        xxxxx
        <%}%></td>
    </tr>
    <%} else {%>
    <tr>
      <td colspan="3" height="25"><em>&nbsp; Not applicable</em></td>
    </tr>
    <%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDDD">
      <td height="20" colspan="2"><strong>&nbsp;<font size="2"><%=strCount[iCount++]%>&#8211; RESIDENCE DATA</font></strong></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="bottom">&nbsp; <font color="#0000FF"><u>Home Address: </u></font></td>
    </tr>
    <tr>
      <td width="60%" height="20" valign="bottom">&nbsp; Apartment Name/House
        No./Street/Barangay </td>
      <td width="40%" valign="bottom">City/Municipality </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(37),"xxxxx")%></td>
      <td valign="bottom"><%=WI.getStrValue(vEditInfo[0].elementAt(38),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Province/State </td>
      <td valign="bottom">Country</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(39),"xxxxx")%></td>
      <td valign="bottom"><%=WI.getStrValue(vEditInfo[0].elementAt(40),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Zipcode</td>
      <td valign="bottom">Telephone Nos. </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(41),"xxxxx")%></td>
      <td valign="bottom"><%=WI.getStrValue(vEditInfo[0].elementAt(42),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="bottom">&nbsp; <font color="#0000FF"><u>Current Contact Address: </u></font></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Contact
        Person/Guardian Name </td>
      <td valign="bottom">Relation</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(43),"xxxxx")%></td>
      <td valign="bottom"><%=WI.getStrValue(vEditInfo[0].elementAt(44),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Apartment
        Name/House No./Street/Barangay </td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2" height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(45),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; City/Municipality</td>
      <td valign="bottom">Province/State </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(46),"xxxxx")%></td>
      <td valign="bottom"><%=WI.getStrValue(vEditInfo[0].elementAt(47),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Country </td>
      <td valign="bottom">Zipcode </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(48),"xxxxx")%></td>
      <td valign="bottom"><%=WI.getStrValue(vEditInfo[0].elementAt(49),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Telephone
        Nos.</td>
      <td valign="bottom">Email Address </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(50),"xxxxx")%></td>
      <td valign="bottom"><%=WI.getStrValue(vEditInfo[0].elementAt(51),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="bottom">&nbsp; <font color="#0000FF"><u>Emergency
        Contact Address: (if not same as above)</u></font></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Contact
        Person Name </td>
      <td valign="bottom">Relation</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(52),"xxxxx")%></td>
      <td valign="bottom"><%=WI.getStrValue(vEditInfo[0].elementAt(53),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Apartment
        Name/House No./Street/Barangay </td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2" height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(54),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; City/Municipality</td>
      <td valign="bottom">Province/State </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(55),"xxxxx")%></td>
      <td valign="bottom"><%=WI.getStrValue(vEditInfo[0].elementAt(56),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Country</td>
      <td valign="bottom">Zipcode</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(57),"xxxxx")%></td>
      <td valign="bottom"><%=WI.getStrValue(vEditInfo[0].elementAt(58),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Telephone
        Nos. </td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(59),"xxxxx")%></td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDDD">
      <td height="20" colspan="6"><strong><font size="2">&nbsp; <%=strCount[iCount++]%> &#8211; PHYSICAL DESCRIPTION</font></strong></td>
    </tr>
    <tr valign="bottom">
      <td width="16%" height="20">&nbsp; Height(cms)</td>
      <td width="16%">Weight(lbs)</td>
      <td width="16%">Built</td>
      <td width="16%">Eye color</td>
      <td width="17%">Hair color</td>
      <td width="19%">Complexion</td>
    </tr>
    <tr>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(60),"xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(61),"xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(62),"xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(63),"xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(64),"xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(65),"xxxxx")%></td>
    </tr>
    <tr>
      <td colspan="3" height="20">&nbsp; Other Distinguishing Features </td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(66),"xxxxx")%></td>
    </tr>
    <tr>
      <td colspan="3" height="20">&nbsp; Physical Handicap or Disability (if any) </td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(67),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="10" colspan="6">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDDD">
      <td height="20" colspan="2"><strong><font size="2" >&nbsp; <%=strCount[iCount++]%> &#8211; FAMILY DATA</font></strong></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="bottom">&nbsp; <font color="#0000FF"><u>Parents:</u></font></td>
    </tr>
    <tr>
      <td width="60%" height="20" valign="bottom">&nbsp;
        Father&#8217;s Name </td>
      <td width="40%" valign="bottom">Occupation</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(68),"xxxxx")%></td>
      <td valign="bottom"><%=WI.getStrValue(vEditInfo[0].elementAt(69),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Company Name </td>
      <td valign="bottom">Telephone Nos. </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(70),"xxxxx")%></td>
      <td valign="bottom"><%=WI.getStrValue(vEditInfo[0].elementAt(71),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Company
        Address</td>
      <td valign="bottom">Father&#8217;s Email Address </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(72),"xxxxx")%></td>
      <td valign="bottom"><%=WI.getStrValue(vEditInfo[0].elementAt(73),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Mother&#8217;s
        Name </td>
      <td valign="bottom">Occupation</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(74),"xxxxx")%></td>
      <td valign="bottom"><%=WI.getStrValue(vEditInfo[0].elementAt(75),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Company Name </td>
      <td valign="bottom">Telephone Nos. </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(76),"xxxxx")%></td>
      <td valign="bottom"><%=WI.getStrValue(vEditInfo[0].elementAt(77),"xxxxx")%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Company
        Address</td>
      <td valign="bottom">Mother&#8217;s Email Address </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(78),"xxxxx")%></td>
      <td valign="bottom"><%=WI.getStrValue(vEditInfo[0].elementAt(79),"xxxxx")%></td>
    </tr>
  </table>
  <%if (vEditInfo[1]!= null && vEditInfo[1].size()>0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="34%" height="20">&nbsp; <font color="#0000FF">Brother(s)/Sister(s):</font></td>
      <td width="33%">&nbsp;</td>
      <td width="33%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp; <u>NAME</u></td>
      <td><u>COURSE/OCCUPATION </u></td>
      <td><u>SCHOOL/COMPANY</u></td>
    </tr>
    <%

for(int i=0; i<vEditInfo[1].size();){
++i;
if(vEditInfo[1].size() > j)
	strTemp = WI.getStrValue(vEditInfo[1].elementAt(j++));
else
	strTemp = "";%>
    <tr>
      <td height="25">&nbsp; &nbsp;<%=strTemp%></td>
      <%
if(vEditInfo[1].size() > j)
	strTemp = WI.getStrValue(vEditInfo[1].elementAt(j++));
%>
      <td><%=strTemp%></td>
      <%
if(vEditInfo[1].size() > j)
	strTemp = WI.getStrValue(vEditInfo[1].elementAt(j++));
++j;
%>
      <td><%=strTemp%></td>
    </tr>
    <%} %>
  </table>
  <%}%>
  <% if(strSchoolCode.startsWith("UI") ){%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#DDDDDD">
      <td height="20" colspan="3"><strong><font size="2" >&nbsp; <%=strCount[iCount++]%> &#8211; FINANCIAL DATA</font></strong></td>
    </tr>
    <%if(vEditInfo[0].elementAt(89) != null){%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2"> Student is Employed? YES </td>
    </tr>
    <tr id="tr_1">
      <td height="25">&nbsp;</td>
      <td width="57%">Occupation</td>
      <td width="41%">Company Name</td>
    </tr>
    <tr id="tr_2">
      <td height="25">&nbsp;</td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(89),"xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(90),"xxxxx")%></td>
    </tr>
    <tr id="tr_3">
      <td height="25">&nbsp;</td>
      <td>Company Address</td>
      <td>&nbsp;</td>
    </tr>
    <tr id="tr_4">
      <td height="25">&nbsp;</td>
      <td colspan="2"><%=WI.getStrValue(vEditInfo[0].elementAt(91),"xxxxx")%></td>
    </tr>
    <tr id="tr_5">
      <td height="25">&nbsp;</td>
      <td>Telephone Numbers</td>
      <td>Source of Income</td>
    </tr>
    <tr id="tr_6">
      <td height="25">&nbsp;</td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(92),"xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[0].elementAt(93),"xxxxx")%></td>
    </tr>
    <tr id="tr_7">
      <td height="25">&nbsp;</td>
      <td>Range of Income</td>
      <td>&nbsp;</td>
    </tr>
    <tr id="tr_8">
      <td height="25">&nbsp;</td>
      <td><%strTemp = WI.getStrValue(vEditInfo[0].elementAt(94),"0");%>
        <%=strIncome[Integer.parseInt(strTemp)]%></td>
      <td>&nbsp;</td>
    </tr>
    <%} else {%>
    <tr>
      <td colspan="3" height="25"> Student is Employed? NO </td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDDD">
      <td height="20" colspan="4"><strong><font size="2" >&nbsp; <%=strCount[iCount++]%> &#8211; EDUCATIONAL BACKGROUND</font></strong></td>
    </tr>
    <tr>
      <td width="15%" height="25">&nbsp;</td>
      <td width="29%"><u>NAME</u></td>
      <td width="26%"><u>COURSE/YEAR GRADUATED</u></td>
      <td width="30%"><u>HONORS/AWARDS</u></td>
    </tr>
    <%
j =0;
if(vEditInfo[2] != null && vEditInfo[2].size() > j && vEditInfo[2].elementAt(j) != null && 
	((String)vEditInfo[2].elementAt(j++)).compareToIgnoreCase("elementary") ==0){%>
    <tr>
      <td height="25">&nbsp; Elementary</td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++),"xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++),"xxxxx")%> <%=WI.getStrValue(vEditInfo[2].elementAt(j++)," xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++),"xxxxx")%></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="25">&nbsp; Elementary</td>
      <td>xxxxx</td>
      <td>xxxxx</td>
      <td>xxxxx</td>
    </tr>
    <%}if(vEditInfo[2] != null && vEditInfo[2].size() > j &&  vEditInfo[2].elementAt(j) != null && 
	((String)vEditInfo[2].elementAt(j++)).compareToIgnoreCase("High school") ==0){%>
    <tr>
      <td height="25">&nbsp; High School</td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++),"xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++),"xxxxx")%><%=WI.getStrValue(vEditInfo[2].elementAt(j++)," xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++),"xxxxx")%></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="25">&nbsp; High School</td>
      <td>xxxxx</td>
      <td>xxxxx</td>
      <td>xxxxx</td>
    </tr>
    <%}if(vEditInfo[2] != null && vEditInfo[2].size() > j &&  vEditInfo[2].elementAt(j) != null &&
	((String)vEditInfo[2].elementAt(j++)).compareToIgnoreCase("College") ==0){%>
    <tr>
      <td height="25">&nbsp; College</td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++),"xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++),"xxxxx")%><%=WI.getStrValue(vEditInfo[2].elementAt(j++)," xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++),"xxxxx")%></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="25">&nbsp; College</td>
      <td>xxxxx</td>
      <td>xxxxx</td>
      <td>xxxxx</td>
    </tr>
    <%}if(vEditInfo[2] != null && vEditInfo[2].size() > j &&  vEditInfo[2].elementAt(j) != null &&
	((String)vEditInfo[2].elementAt(j++)).compareToIgnoreCase("PG") ==0){%>
    <tr>
      <td height="25">&nbsp; Post Graduate</td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++),"xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++),"xxxxx")%><%=WI.getStrValue(vEditInfo[2].elementAt(j++)," xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++),"xxxxx")%></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="25">&nbsp; Post Graduate</td>
      <td>xxxxx</td>
      <td>xxxxx</td>
      <td>xxxxx</td>
    </tr>
    <%}if(vEditInfo[2] != null && vEditInfo[2].size() > j &&  vEditInfo[2].elementAt(j) != null &&
	((String)vEditInfo[2].elementAt(j++)).compareToIgnoreCase("Vocatinal") ==0){%>
    <tr>
      <td height="25">&nbsp; Vocational</td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++),"xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++),"xxxxx")%> <%=WI.getStrValue(vEditInfo[2].elementAt(j++)," xxxxx")%></td>
      <td><%=WI.getStrValue(vEditInfo[2].elementAt(j++),"xxxxx")%></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="25">&nbsp; Vocational</td>
      <td>xxxxx</td>
      <td>xxxxx</td>
      <td>xxxxx</td>
    </tr>
    <%}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDDD">
      <td height="20"  colspan="2"><strong><font size="2" >&nbsp; <%=strCount[iCount++]%> &#8211; GENERAL QUALIFICATION</font></strong></td>
    </tr>
    <tr>
      <td width="10%">&nbsp;<font color="#0000FF">Languages:</font></td>
      <td height="25" width="90%">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(80),"xxxxx")%></td>
    </tr>
    <tr>
      <td>&nbsp;<font color="#0000FF">Hobbies:</font></td>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(81),"xxxxx")%></td>
    </tr>
    <tr>
      <td><font color="#0000FF">&nbsp;Skills:</font></td>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(82),"xxxxx")%></td>
    </tr>
    <tr>
      <td><font color="#0000FF">&nbsp;Talents:</font></td>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(83),"xxxxx")%></td>
    </tr>
    <tr>
      <td>&nbsp;<font color="#0000FF">Sports:</font></td>
      <td height="25">&nbsp; <%=WI.getStrValue(vEditInfo[0].elementAt(84),"xxxxx")%></td>
    </tr>
    <%if (vEditInfo[0].elementAt(85)!= null && ((String)vEditInfo[0].elementAt(85)).length()>0){%>
    <tr>
      <td colspan="2" valign="bottom"><font color="#0000FF">&nbsp;Honors/Awards/Merits: </font> </td>
    </tr>
    <tr>
      <td >&nbsp;</td>
      <td height="25"><%=WI.getStrValue(vEditInfo[0].elementAt(85))%></td>
    </tr>
    <%}
    if (vEditInfo[0].elementAt(86)!= null && ((String)vEditInfo[0].elementAt(86)).length()>0){%>
    <tr>
      <td colspan="2" valign="bottom">&nbsp;<font color="#0000FF">Extra-Curricular Activities
        : </font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25"><%=WI.getStrValue(vEditInfo[0].elementAt(86))%></td>
    </tr>
    <%}
    if (vEditInfo[0].elementAt(88)!= null && ((String)vEditInfo[0].elementAt(88)).length()>0){%>
    <tr>
      <td colspan="2" valign="bottom">&nbsp;<font color="#0000FF">Why am I taking 
        this course?</font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25"><%=WI.getStrValue(vEditInfo[0].elementAt(88))%></td>
    </tr>
    <%}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDDD">
      <td height="20" colspan="2"><strong><font size="2">&nbsp; <%=strCount[iCount++]%> &#8211; REFERENCES</font></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;&nbsp;&nbsp;Write two or three references 
        who can vouch or guarantee for your total behavior.</td>
    </tr>
    <tr>
      <td width="37%" height="25">&nbsp;&nbsp;&nbsp;<u>NAME</u></td>
      <td width="63%"><u>ADDRESS/TEL. NOS.</u></td>
    </tr>
    <%if(vEditInfo[3]!=null && vEditInfo[3].size()>0){%>
    <%//System.out.println(vEditInfo[3]);
j = 0;
if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
%>
    <tr>
      <td height="25">&nbsp;&nbsp; <%=strTemp%></td>
      <%
if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
++j;
%>
      <td><%=strTemp%></td>
    </tr>
    <%if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
%>
    <tr>
      <td height="25">&nbsp;&nbsp; <%=strTemp%></td>
      <%if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
++j;
%>
      <td><%=strTemp%></td>
    </tr>
    <%if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
%>
    <tr>
      <td height="25">&nbsp;&nbsp; <%=strTemp%></td>
      <%if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
%>
      <td><%=strTemp%></td>
    </tr>
    <%} else {%>
    <tr>
      <td>&nbsp;&nbsp; xxxxx</td>
      <td>&nbsp;xxxxx</td>
    </tr>
    <%}%>
  </table>
 <%
   vRetResult = pInfo.getRecruitmentInfo(dbOP, request,4);
  if(vRetResult != null && vRetResult.size() > 0)
		{    %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDDD">
      <td height="20" colspan="3"><strong><font size="2">&nbsp; <%=strCount[iCount++]%> &#8211; Admission / Registration </font></strong></td>
      </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;How did you know <%= WI.getStrValue(strSchoolName) %> ? (Please check the box) </td>
      </tr>
		 <%
		 iCount = 1;
		
	for(int i = 0; i < vRetResult.size(); i += 2, iCount++)
		{	
		
      if(vRecruit.indexOf((String)vRetResult.elementAt(i)) >-1)
	   	strErrMsg = "checked";
		else
			strErrMsg = "";
				  
 	
  %>
    <tr>
      <td colspan="2">&nbsp;&nbsp;
        <input type="checkbox" name="detail_index_<%=iCount%>" 
			value="<%=(String)vRetResult.elementAt(i)%>" disabled="disabled" <%=strErrMsg%>/>
        <%=(String)vRetResult.elementAt(i+1)%> </td>
    </tr>
    <%}%>
	 
    <tr>
    <%
	 strTemp = "";
	 if(vRecruit !=null && vRecruit.size()>0)
	 	strTemp = WI.getStrValue((String)vRecruit.elementAt(1));		
	%>
      <td colspan="2">&nbsp;&nbsp; others : <%=strTemp%>      </td>
    </tr>
    <tr>
      <td height="25" colspan="3"></td>
      </tr>
    <tr>
      <%
		 strTemp = "";
	 if(vRecruit !=null && vRecruit.size()>0)
	 	strTemp = WI.getStrValue((String)vRecruit.elementAt(0));	
	%>
      <td width="27%" height="25">&nbsp;&nbsp; IF through a person, please specify: </td>
      <td width="73%"><%=strTemp%></td>
    </tr>
  </table>
 <%}%> 
  
  
  <script language="JavaScript">
	window.print();
  </script>
  <%}%>
  <input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
