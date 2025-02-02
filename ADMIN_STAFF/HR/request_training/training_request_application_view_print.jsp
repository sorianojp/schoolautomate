<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
WebInterface WI = new WebInterface(request);
boolean bolIsSchool = false;

if ((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
	
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	

    TD {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }	
</style>
</head>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");


//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-Request for Trainings",
								"training_request_application_view_print.jsp.jsp");

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
														"HR Management","REQUEST FOR TRAININGS",request.getRemoteAddr(),
														"training_request_application_view_print.jsp.jsp");

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
Vector vRetResult = null;
String strInfoIndex = request.getParameter("info_index");

String[] astrSortByName = {"Employee ID","Lastname","Firstname","College","Office","Category","Type","Status"};
String[] astrSortByVal  = {"id_number","lname","fname","c_code","d_name","is_internal","seminar_type",
							  "TRNG_APPL_STAT"};
							  
							  
int iSearchResult = 0;
							  
HRInfoLicenseETSkillTraining hrCon = new HRInfoLicenseETSkillTraining(request);


vRetResult = hrCon.searchTrngAppl(dbOP);
if (vRetResult == null) 
	strErrMsg  = hrCon.getErrMsg();
else
	iSearchResult = hrCon.getSearchCount();

%>
<body onLoad="window.print();">
  <% if (vRetResult != null) {%>
  
<table width="100%" border="0"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td><div align="center"><strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br>
          <font size ="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br>
          <font size ="1"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> 
        </div></td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td><b>TOTAL RESULT: <%=iSearchResult%></b></td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
  </tr>
</table>
  <table width="100%" border="0" align="center"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="28" colspan="8" class="thinborder"><div align="center"><strong>LIST OF TRAINING/SEMINAR REQUEST(S)</strong></div></td>
    </tr>
    <tr> 
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE ID</strong></font></div></td>
      <td width="20%" height="25" class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE NAME </strong></font></div></td>
      <td width="19%" height="25" class="thinborder"> <div align="center"><font size="1"><strong><%if(bolIsSchool){%>COLLEGE<%}else{%>DEPARTMENT<%}%>/OFFICE </strong></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><strong>CATEGORY</strong></font></div></td>
      <td width="8%" height="25" class="thinborder"><div align="center"><font size="1"><strong>TYPE <br>(BUDGET)</strong></font></div></td>
      <td width="8%" height="25" class="thinborder"><div align="center"><font size="1"><strong>DATE FILED </strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>INCLUSIVE DATES </strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>STATUS</strong></font></div></td>
    </tr>
    <% 
	String[] astrIsInternal={"Internal", "External"};
	String[] astrType={"&nbsp;", "Official Time","Official Bus.","Rep. / Proxy" };
	String[] astrStat ={"Disapproved","Approved","Pending", "Pending - VP", "Pending - Pres"};
	
	for (int i =0; i < vRetResult.size() ; i+=14){%>
    <tr> 
      <td width="8%" height="32" class="thinborder"><%=(String)vRetResult.elementAt(i+7)%></td>
      <td width="17%" class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+8),
	  							(String)vRetResult.elementAt(i+9),(String)vRetResult.elementAt(i+10),4)%></td>
      <% if ((String)vRetResult.elementAt(i+11) != null){
	 	strTemp = (String)vRetResult.elementAt(i+11) + WI.getStrValue((String)vRetResult.elementAt(i+12)," :: ", "","");
	 } else strTemp = (String)vRetResult.elementAt(i+12);%>
      <td width="17%" class="thinborder"><%=strTemp%></td>
      <td width="7%" class="thinborder"><%=astrIsInternal[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"0"))]%></td>
      <td width="8%" class="thinborder">&nbsp;<%=/**astrType[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+4),"0"))]**/
	   WI.getStrValue((String)vRetResult.elementAt(i+4), "") +
										  WI.getStrValue((String)vRetResult.elementAt(i+13),"<br>(",")","")%></td>
      <td width="8%" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td width="12%" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5))%> <%=WI.getStrValue((String)vRetResult.elementAt(i+6)," - ","","")%> </td>
      <td width="8%" class="thinborder"><%=astrStat[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+2),"2"))]%></td>
    </tr>
    <%} // end for loop %>
  </table>
 <%} // end if vRetResult != null%>
</body>
</html>
<%
	dbOP.cleanUP();
%>
