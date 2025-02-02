<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null) 
		strSchCode = "";
%>
	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>Personnel Trainings</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
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
														"hr_personnel_trainings.jsp");
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


HRInfoLicenseETSkillTraining hrCon = new HRInfoLicenseETSkillTraining(dbOP);


strTemp = WI.fillTextValue("emp_id");
if (bolMyHome) 
	strTemp = (String)request.getSession(false).getAttribute("userId");


if(bolIsApplicant){
	hr.HRApplNew hrApplNew = new hr.HRApplNew();
	vEmpRec = hrApplNew.operateOnApplication(dbOP, request,3);//view one
	if(vEmpRec == null)
		strErrMsg = hrApplNew.getErrMsg();
}else{	
	enrollment.Authentication authentication = new enrollment.Authentication();
	vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vEmpRec == null)
		strErrMsg = authentication.getErrMsg();
}

vRetResult = hrCon.operateOnTraining(dbOP,request,4);

if (vRetResult == null){
	strErrMsg = hrCon.getErrMsg();
}

String[] astrSemimarType={"N/A","Official Time","Official Business","Representative/Proxy",""};
%>
<body onLoad="javascript:window.print()">
<% if (strErrMsg != null) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr >
      <td width="55%" height="25"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
	</tr>
  </table>
<%} if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" >
    <tr>
      <td width="105%"><% if (!WI.fillTextValue("applicant_").equals("1")) {%>
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
              <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br>
			<% if (!bolIsApplicant) {%>
			  <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
		  <% if (!strSchCode.startsWith("UI") && 
			  		!strSchCode.startsWith("AUF")) {%>
          <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%>
		  <%} // do not show length of service%></font> 
			 <%}%>
            </td>
          </tr>
        </table>
<%}else{%>
        <table width="400" height="77" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../faculty_img/"+WI.fillTextValue("emp_id").toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\">";%>
              <%=strTemp%><br> <br> <br> <strong><%=WI.formatName((String)vEmpRec.elementAt(1),
			  								(String)vEmpRec.elementAt(2),
						 				    (String)vEmpRec.elementAt(3),4)%></strong><br>
              Position Applying for: <%=WI.getStrValue(vEmpRec.elementAt(11))%><br> 
              <%=WI.getStrValue(vEmpRec.elementAt(5),"<br>","")%> 
              <!-- email -->
              <%=WI.getStrValue(vEmpRec.elementAt(4))%> 
              <!-- contact number. -->
            </td>
          </tr>
        </table>
<%}%>  
  
  
  <%  if (vRetResult != null && vRetResult.size() > 0) { %>
        <table width="99%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
          <tr> 
            <td height="25" colspan="4" align="center" class="thinborder"><strong>EMPLOYEE'S 
                TRAINING/SEMINAR RECORD</strong></td>
          </tr>
          <tr> 
            <td width="28%" align="center" class="thinborder"><strong>TRAINING 
              / SEMINARS</strong></td>
            <td width="17%" height="19" align="center" class="thinborder"><strong>TYPE 
              / BUDGET</strong></td>
            <td width="23%" align="center" class="thinborder"><strong>VENUE</strong></td>
            <td width="16%" align="center" class="thinborder"><strong>DATE</strong></td>
          </tr>
          <% for (int i=0; i < vRetResult.size() ; i+=19) { %>
          <tr> 
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+6),"<br> Conducted by : <strong>","</strong>","")%></td>
            <td class="thinborder">&nbsp;<%//=astrSemimarType[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+14),"0"))]%> 
			<%=WI.getStrValue((String)vRetResult.elementAt(i + 18)," - ")%>
			<%=WI.getStrValue((String)vRetResult.elementAt(i+13)," <br> &nbsp;Budget :","","")%></td>
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></td>
            <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;") + 
				WI.getStrValue((String)vRetResult.elementAt(i+8),"<br>&nbsp; to ", "","")%></td>
          </tr>
          <%} // end for loop %>
        </table>
 <%} // end table listing %>
      
<%}%>
</body>
</html>
<%
	dbOP.cleanUP();
%>

