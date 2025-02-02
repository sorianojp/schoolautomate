<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoGAExtraActivityOffense"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	String strSchCode  = 
				WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

//strColorScheme is never null. it has value always.
 %>	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Personnel Offense</title>
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

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_personnel_education.jsp");

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

Vector vEmpRec = new Vector();
Vector vRetResult = new Vector();
boolean bNoError = false;
boolean bolNoRecord = false;
String strPrepareToEdit = null;
String strInfoIndex = WI.fillTextValue("info_index");

HRInfoGAExtraActivityOffense hrCon = new HRInfoGAExtraActivityOffense();

int iAction =  -1;

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

	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");

	if (vEmpRec != null && vEmpRec.size() > 0){
		bNoError = true;
	}else{
		strErrMsg = "Employee has no profile.";
		bNoError = false;
	}
}



vRetResult = hrCon.operateOnOffenses(dbOP,request,4);
if (vRetResult == null && strErrMsg== null){
	strErrMsg = hrCon.getErrMsg();
}
//String astrConvAction[] = {"Warning","Written Reprimand", "1st Notice", "2nd Notice","Termination"};

%>
<body onLoad="window.print()">
  <%if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
 
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
		  <% if (!strSchCode.startsWith("UI") && 
			  		!strSchCode.startsWith("AUF")) {%>
          <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%>
		  <%} // do not show length of service%> </font> 
            </td>
          </tr>
</table>
        <% if (vRetResult != null && vRetResult.size() > 0) { %>    
      <table width="100%" border="0" cellpadding="1"  class="thinborder" cellspacing="0">
        <tr> 
          <td height="25" colspan="5" align="center" class="thinborder"><strong>LIST 
            OF OFFENSE(S)</strong></td>
        </tr>
        <tr> 
          <td width="20%"  class="thinborder"> <p align="center"><font size="1"><strong> 
              OFFENSE(S)<br>
              </strong></font></p></td>
          <td width="21%" align="center" class="thinborder"><font size="1"><strong>DETAILS</strong></font></td>
          <td width="15%" align="center" class="thinborder"><font size="1"><strong>DATE 
            OF OFFENSE/REPORTED</strong></font></td>
          <td width="10%" align="center" class="thinborder"><font size="1"><strong>ACTION 
            TAKEN</strong></font></td>
          <td width="10%" align="center" class="thinborder"><font size="1"><strong>EFFECTIVE 
            DATES</strong></font></td>
        </tr>
        <% for (int i=0; i < vRetResult.size(); i+=9) {%>
        <tr> 
          <td class="thinborder" height="23"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp")%></font></td>
          <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp")%></font></td>
          <td align="center" class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp")%></font></td>
          <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%></font></td>
          <td align="center" class="thinborder"><font size="1">				
		  	<%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")+ 
			WI.getStrValue((String)vRetResult.elementAt(i+7)," - " ,"","")%></font></td>
        </tr>
        <%} // end for loop%>
</table>
<%} // end for listing table%>
<%}%>
</body>
</html>

