<%@ page language="java" import="utility.*, health.HMReports ,java.util.Vector " %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<body onLoad="javascript:window.print();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
 
	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	int iSearchResult = 0;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","immunization_rpt.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
														"immunization_rpt.jsp");
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

//end of authenticaion code.
 	HMReports hmReports = new HMReports();
 	
 	vRetResult = hmReports.viewImmunization(dbOP, request);
 	if (vRetResult != null) {	
	boolean bolPageBreak = false;
	int iPage = 1; 
	int iCount = 0;	
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
	int i = 0;
	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size())/(15*iMaxRecPerPage);		
	if((vRetResult.size() % (15*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){%>

<form name="form_">
   <table width="100%" border="0" bgcolor="#FFFFFF" class="thinborder" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="5" align="center" class="thinborder"><strong><font size="2">IMMUNIZATION    SEARCH RESULT </font></strong></td>
    </tr>
    
    <tr style="font-weight:bold" align="center">
      <td width="10%" class="thinborder" style="font-size:9px;">Dosage Schedule </td> 
      <td width="11%" height="25" class="thinborder" style="font-size:9px;">ID #</td>
      <td width="36%" class="thinborder" style="font-size:9px;">Name</td>
      <td width="20%" class="thinborder" style="font-size:9px;"><%if(bolIsSchool){%>Unit/ Colleges<%}else{%>Division/Office<%}%></td>
      <td width="23%" class="thinborder" style="font-size:9px;">Immunization Name</td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=15,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>		
    <tr>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+14)%></td> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+8), (String)vRetResult.elementAt(i+9), (String)vRetResult.elementAt(i+10),4)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+12),WI.getStrValue((String)vRetResult.elementAt(i+13),"&nbsp;"))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%></td>
    </tr>
    <%}%>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
