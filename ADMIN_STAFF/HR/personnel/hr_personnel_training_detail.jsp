<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
String[] strColorScheme = CommonUtil.getColorScheme(5);

	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function CloseWindow(){
	self.close();
}
</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

	//This page is called for applicant as well as for employees, -- do not show search button for applicant.
	boolean bolIsApplicant = false;
	if(WI.fillTextValue("applicant_").compareTo("1") ==0)
		bolIsApplicant = true;

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Traning","hr_personnel_trainings.jsp");

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
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_personnel_education.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 2;
		else 
			iAccessLevel = 1;

		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//
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
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

Vector vEmpRec = null;
Vector vRetResult = null;
Vector vEditInfo = null;

boolean bNoError = false;
boolean bolNoRecord = false;
String strPrepareToEdit = null;
String strInfoIndex = WI.fillTextValue("info_index");

HRInfoLicenseETSkillTraining hrCon = new HRInfoLicenseETSkillTraining(dbOP);

strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}

if (strTemp.trim().length()> 0){

	if(bolIsApplicant){
		hr.HRApplNew hrApplNew = new hr.HRApplNew();
		vEmpRec = hrApplNew.operateOnApplication(dbOP, request,3);//view one
	}else{	
		enrollment.Authentication authentication = new enrollment.Authentication();
		vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
		if(vEmpRec == null || vEmpRec.size() ==0)
			strErrMsg = authentication.getErrMsg();
	}
	if (vEmpRec != null && vEmpRec.size() > 0)	{
		bNoError = true;
	}else{		
		bNoError = false;
	}
}


vRetResult = hrCon.operateOnTraining(dbOP,request,3);

if (vRetResult == null && strErrMsg == null ){
	strErrMsg = hrCon.getErrMsg();
}


String[] astrSemimarType={"N/A","Official Time","Official Business","Representative/Proxy",""};
String[] astrDuration={"Hour(s)","Day(s)","Week(s)","Month(s)","Year(s)"};
%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          TRAININGS/SEMINARS PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" > &nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
      <td height="25" ><a href="javascript:CloseWindow()"><img src="../../../images/close_window.gif" width="71" height="32" align="right" border="0"></a></td>
    </tr>
    <% if (!bolMyHome){%>
    <%}else{%>
    <tr> 
      <td width="56%" height="25">&nbsp;&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong> <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
      <td width="44%">&nbsp;</td>
    </tr>
    <%}%>
  </table>
<%if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="105%"><hr size="1">
        <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%>
              <%=WI.getStrValue(strTemp)%> <br> <br> 
              <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%>
              <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> 
              <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
              <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> 
            </td>
          </tr>
        </table>
        <br>
        <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
          <tr> 
            <td height="25" class="thinborder">Name of Seminar/Training </td>
            <td height="25" class="thinborder"><strong>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(1),"&nbsp;")%></strong></td>
          </tr>
          <tr> 
            <td height="25" class="thinborder">Category </td>
            <td height="25" class="thinborder">&nbsp; <%if(WI.getStrValue((String)vRetResult.elementAt(2),"0").compareTo("0") ==0) {%>
              Internal (Held Inside the  campus) 
              <%}else{%>
              External (Held Outside the  campus) 
              <%}%> </td>
          </tr>
          <tr> 
            <td height="25" class="thinborder">Scope </td>
            <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(12),"&nbsp;")%> </td>
          </tr>
          <tr> 
            <td height="25" class="thinborder">Type</td>
            <td height="25" class="thinborder">&nbsp;<%//=astrSemimarType[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(14),"0"))]%>
			<%=WI.getStrValue((String)vRetResult.elementAt(18)," - ")%>
			</td>
          </tr>
          <tr> 
            <td height="25" class="thinborder">Approved Budget</td>

            <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(13),"&nbsp;")%>
					  <% if (WI.getStrValue((String)vRetResult.elementAt(17)).equals("1")){%> 
					  &nbsp;&nbsp; (university funded)  <%}%>
			</td>
          </tr>
          <tr> 
            <td width="21%" height="25" class="thinborder">Venue</td>
            <td width="79%" height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(3),"&nbsp;")%></td>
          </tr>
	<%if (strSchCode.startsWith("CPU")) {%> 
          <tr>
            <td height="25" class="thinborder">Place </td>
            <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(16),"&nbsp;")%></td>
          </tr>
	<%}%> 
          <tr> 
            <td height="25" class="thinborder">Duration</td>
            <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(4),""," " + astrDuration[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(5),"0"))], "&nbsp;")%> </td>
          </tr>
          <tr> 
            <td height="25" class="thinborder">Conducted by</td>
            <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(6))%></td>
          </tr>
          <tr> 
            <td height="25" class="thinborder">Inclusive Dates</td>
            <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(7),"&nbsp;") + 
				WI.getStrValue((String)vRetResult.elementAt(8),"")%></td>
          </tr>
          <tr> 
            <td height="25" class="thinborder"> Notes: </td>
            <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(9),"&nbsp;")%></td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

<input type="hidden" name="applicant_" value="<%=WI.fillTextValue("applicant_")%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

