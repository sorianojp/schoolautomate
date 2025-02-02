<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoScholarship" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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


	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;
//add security hehol.

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
		if (strSchCode == null ) 
			strSchCode = "";

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_personnel_awards_etc.jsp");

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
														"hr_personnel_awards_etc.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").equals("1"))
			iAccessLevel = 2;
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

Vector vRetResult = null;
Vector vEmpRec = null;

HRInfoScholarship hrS = new HRInfoScholarship();

if (!bolMyHome) 
	strTemp = WI.fillTextValue("emp_id");

enrollment.Authentication authentication = new enrollment.Authentication();
vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");

if (vEmpRec == null || vEmpRec.size() == 0)	{
	strErrMsg = authentication.getErrMsg();
}

vRetResult = hrS.operateOnScholarship(dbOP,request,4);
if (vRetResult == null) 
	strErrMsg = hrS.getErrMsg();

%>
<body onLoad="javascript:window.print()">
<% if (strErrMsg != null) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="300%" height="25" colspan="3">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<%} if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
    <table width="400" border="0" align="center">
    <tr bgcolor="#FFFFFF">
      <td width="100%" valign="middle"><%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%>
          <%=WI.getStrValue(strTemp)%> <br>
          <br>
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
          <br>
          <strong><%=WI.getStrValue(strTemp)%></strong><br>
          <font size="1"><%=WI.getStrValue(strTemp2)%></font><br>
          <font size="1"><%=WI.getStrValue(strTemp3)%></font><br>
          <br>
          <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
		  <% if (!strSchCode.startsWith("UI") && 
			  		!strSchCode.startsWith("AUF")) {%>
          <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%>
		  <%} // do not show length of service%> </font> 
		  </td>
    </tr>
  </table>
  <% vRetResult = hrS.operateOnScholarship(dbOP,request,4);
	if (vRetResult != null && vRetResult.size() > 0){ %>
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="5" align="center" class="thinborder"><strong>EMPLOYEE'S 
        AWARDS RECORD</strong></td>
    </tr>
    <tr> 
      <td width="16%" class="thinborder"><font size="1"><strong>&nbsp;REWARD TYPE</strong></font></td>
      <td width="21%" class="thinborder"><font size="1"><strong>&nbsp;NAME</strong></font></td>
      <td width="31%" class="thinborder"><font size="1"><strong>GRANTING AGENCY/ORGANIZATION <br>
      (<font size="1">PLACE</font>) </strong></font></td>
      <td width="10%" class="thinborder"><font size="1"><strong>&nbsp;DATE </strong></font></td>
<% strTemp = "REMARKS ";
	if (strSchCode.startsWith("UI"))
	strTemp += "/ AMOUNT" ;
%>
      <td width="22%" class="thinborder"><strong><font size="1">&nbsp;<%=strTemp%></font></strong></td>
    </tr>
    <% for (int i =0 ; i < vRetResult.size() ; i+=13){ %>
    <tr> 
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+1))%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"<br>(",")", "&nbsp;")%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></font></td>
	  
<% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6));
	if (strTemp.length() == 0)
		strTemp =  WI.getStrValue((String)vRetResult.elementAt(i+9),"&nbsp;");
	else
		strTemp += " / " + WI.getStrValue((String)vRetResult.elementAt(i+9));
					
%>
      <td class="thinborder">
	    <font size="1"><%=strTemp%></font></td>
    </tr>
    <%} // end for loop %>
  </table>
  <%} // end listing
} // end vEmpRec != null%>

</body>
</html>
<%
	dbOP.cleanUP();
%>
