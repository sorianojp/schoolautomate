<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = false;
	if(WI.fillTextValue("my_home").compareTo("1") == 0 ){
		bolMyHome = true;
	}
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Request Training","training_request_application.jsp");

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
														"training_request_application.jsp");
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


boolean bNoError = false;
boolean bolNoRecord = false;
String strPrepareToEdit = null;


HRInfoLicenseETSkillTraining hrCon = new HRInfoLicenseETSkillTraining();

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

vRetResult = hrCon.operateOnTrainingAppl(dbOP,request,3);
if (vRetResult== null && strErrMsg == null){
	strErrMsg = hrCon.getErrMsg();
}
%>
<body>
<form action="./training_request_application.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3"><div align="center"><strong>::::  REQUEST 
          FOR TRAININGS PAGE ::::</strong></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="3" > &nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr > 
      <td width="32%" height="25" >&nbsp;&nbsp;Employee ID : <%=WI.getStrValue(strTemp)%> <input name="emp_id" type= "hidden" value="<%=WI.getStrValue(strTemp)%>"></td>
      <td width="35%" >&nbsp;</td>
      <td width="33%" >Date Filed :<font color="#FF0000"> <strong><%=WI.getStrValue((String)vRetResult.elementAt(1))%></strong></font></td>
    </tr>
  </table>
<%
  if ( vRetResult != null){ 
	String[] astrIsInternal={"Internal", "External"};
	String[] astrType={"&nbsp;", "Official Time","Official Bus.","Rep. / Proxy" };
	String[] astrDurationUnit ={"hour(s)", "day(s)", "week(s)","month(s)","year(s)"};
	String[] astrStat ={"Disapproved","Approved","Pending", "Pending - VP", "Pending - Pres"};	
	String[] astrApproval ={"Disapproved","Approved","Pending", "Not Required"};	
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="100%">
        <table width="95%" border="0" align="center" cellpadding="3" cellspacing="0" class="thinborder">
          <tr> 
            <td height="30" colspan="3" class="thinborder"><div align="center"><strong> 
                <%=(String)vRetResult.elementAt(21)%></strong></div></td>
          </tr>
          <tr> 
            <td height="30" class="thinborder">Category </td>
            <td height="30" colspan="2" class="thinborder"> <%=astrIsInternal[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(17),"0"))]%> </td>
          </tr>
          <tr> 
            <td height="25" class="thinborder">Scope </td>
            <td height="25" colspan="2" class="thinborder"> <%=WI.getStrValue((String)vRetResult.elementAt(19),"&nbsp;")%> </td>
          </tr>
          <tr> 
            <td height="28" class="thinborder">Type</td>
            <td height="28" colspan="2" class="thinborder"><%//=astrType[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(25),"0"))]%>
			<%=WI.getStrValue(vRetResult.elementAt(33),"&nbsp;")%>
			</td>
          </tr>
          <tr> 
            <td height="30" class="thinborder">Budget</td>
            <td height="30" colspan="2" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(26),"N/A")%></td>
          </tr>
          <tr> 
            <td width="19%" height="30" class="thinborder">Venue</td>
            <td height="30" colspan="2" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(22),"&nbsp")%> </td>
          </tr>
<% if (strSchCode.startsWith("CPU")) {%> 
          <tr>
            <td height="30" class="thinborder">Place</td>
            <td height="30" colspan="2" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(32),"&nbsp")%> </td>
          </tr>
<%}%> 
          <tr> 
            <td height="30" class="thinborder">Duration</td>
		<%strTemp = WI.getStrValue((String)vRetResult.elementAt(23));
		  if (strTemp.length() == 0) strTemp = "&nbsp";
		  else strTemp +=astrDurationUnit[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(24),"0"))];%>
            <td height="30" colspan="2" class="thinborder"><%=strTemp%> </td>
          </tr>
          <tr> 
            <td height="30" class="thinborder">Conducted by</td>
            <td height="30" colspan="2" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(28),"&nbsp;")%></td>
          </tr>
          <tr> 
            <td height="30" class="thinborder">Inclusive Dates</td>
            <td height="30" colspan="2" class="thinborder"><strong><font color="#0000FF"><%=WI.getStrValue((String)vRetResult.elementAt(29))%> <%=WI.getStrValue((String)vRetResult.elementAt(30),"&nbsp;&nbsp;  -  &nbsp;&nbsp;","","")%> </font></strong></td>
          </tr>
          <tr> 
            <td height="30" class="thinborder">Notes<br></td>
            <td height="30" colspan="2" class="thinborder"> <%=WI.getStrValue((String)vRetResult.elementAt(31),"&nbsp;")%></td>
          </tr>
          <tr> 
            <td height="30" colspan="3" class="thinborder">&nbsp;</td>
          </tr>
          <tr> 
            <td height="30" class="thinborder">Approval by 1st signatory </td>
            <td width="23%" height="30" class="thinborder"><%=astrApproval[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(2),"2"))]%> </td>
            <td width="58%" class="thinborder">Date : <%=WI.getStrValue((String)vRetResult.elementAt(3))%></td>
          </tr>
          <tr> 
            <td height="30" class="thinborder"> Approval by 2nd signatory</td>
            <td height="30" class="thinborder"><%=astrApproval[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(4),"2"))]%> </td>
            <td height="30" class="thinborder">Date : <%= WI.getStrValue((String)vRetResult.elementAt(5))%> </td>
          </tr>
          <tr> 
            <td height="30" class="thinborder">Approval by 3rd signatory</td>
            <td height="30" class="thinborder"><%=astrApproval[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(6),"2"))]%></td>
            <td height="30" class="thinborder">Date : <%=WI.getStrValue((String)vRetResult.elementAt(7))%> </td>
          </tr>
          <tr> 
            <td height="30" colspan="3" class="thinborder">&nbsp;</td>
          </tr>
          <tr> 
            <td height="30" class="thinborder">Substitute :</td>
            <td height="30" colspan="2" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(12),""," - " ,"")  + WI.formatName(WI.getStrValue((String)vRetResult.elementAt(9)),
			(String)vRetResult.elementAt(10),WI.getStrValue((String)vRetResult.elementAt(11)),4)%> &nbsp;</td>
          </tr>
          <tr> 
            <td height="30" class="thinborder">Request Status :</td>
            <td height="30" colspan="2" class="thinborder"><%=astrStat[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(13),"2"))]%></td>
          </tr>
          <tr> 
            <td height="30" class="thinborder">Date of Status Update </td>
            <td height="30" colspan="2" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(14),"&nbsp;")%></td>
          </tr>
          <tr> 
            <td height="30" class="thinborder">Remarks : </td>
            <td height="30" colspan="2" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(15),"&nbsp")%></td>
          </tr>
        </table>
        
      </td>
    </tr>
  </table>
<%}%>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

