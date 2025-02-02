<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Payslip</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PayrollConfig" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","cash_gift_setting.jsp");

	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"cash_gift_setting.jsp");
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

	PayrollConfig prConfig = new PayrollConfig();
	Vector vRetResult = null;
	boolean bolPageBreak = false;
	vRetResult = prConfig.operateOnUserGiftSetting(dbOP, request,  4);
	if (vRetResult != null) {
		int i = 0; 
		int iPage = 1; 
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iItems = 0;
	
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;

 	   if((WI.fillTextValue("with_schedule")).equals("1")){
	   	iItems = 10;
	   }else{
	   	iItems = 8;
	   }
		
		int iTotalPages = vRetResult.size()/(iItems*iMaxRecPerPage);	
		if((vRetResult.size() % (iItems*iMaxRecPerPage)) > 0) ++iTotalPages;
  	for (;iNumRec < vRetResult.size();iPage++){		
%>

<body onLoad="javascript:window.print()">
<form name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    
    <tr class="thinborder"> 
	  <%
	  if((WI.fillTextValue("with_schedule")).equals("1"))
	    strTemp = "EMPLOYEES WITH CASH GIFT SETTING ";
	  else
	    strTemp = "EMPLOYEES WITHOUT CASH GIFT SETTING";
	  
	  %>	
      <td height="23" colspan="5" align="center" class="thinborder"><strong><%=strTemp%></strong></td>	  
    </tr>
    <tr class="thinborder">
      <td width="11%" align="center" class="thinborder"><strong><strong>EMPLOYEE ID </strong></strong></td> 
      <td width="32%" height="25" align="center" class="thinborder"><strong><strong>EMPLOYEE NAME </strong></strong></td>
      <td class="thinborder" width="23%" align="center"><strong><strong>OFFICE</strong></strong></td>
	    <td width="19%" align="center" class="thinborder"><strong>LENGTH OF SERVICE </strong></td>
	    <%
	  if((WI.fillTextValue("with_schedule")).equals("1")){
	  %>
      <td width="15%" align="center" class="thinborder"><strong>GIFT NAME </strong></td>
      <%}%>
    </tr>

    <% for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=iItems, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>		
    <tr bgcolor="#FFFFFF" class="thinborder">
      <%
		  	strTemp = (String)vRetResult.elementAt(i+1);
	  %>
      <td class="thinborder" >&nbsp;<%=strTemp%></td> 

      <td height="25" class="thinborder" >&nbsp;<font size="1"><strong><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>

      <%	   
	    if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
	  %>							
      <td class="thinborder" >&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5)," ")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6)," ")%> </td>
	    <td class="thinborder" >&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
	    <%if((WI.fillTextValue("with_schedule")).equals("1")){%>	  
      <td class="thinborder" >&nbsp;<%=(String)vRetResult.elementAt(i+8)%></td>
      <%}%>
    </tr>
    <%} // end for loop%>	
  </table>  
    <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.
	} //end outer for loop
} //end end upper most if (vRetResult !=null)%>	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>