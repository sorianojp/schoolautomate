<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscDeduction, payroll.PReDTRME" buffer="16kb" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
///added code for HR/companies.

boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
	String strEmpID = null;	
//add security here.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Detailed Recurring deductions Payment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css"> 
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script> 

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
  
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions (Per Employee)","recurring_ledger.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
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
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"recurring_ledger.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vPersonalDetails = null;
Vector vRetResult = null;
Vector vEmpList = null;
Vector vDate = null;
double dTemp = 0d;
double dTotal = 0d;

	PRMiscDeduction prd = new PRMiscDeduction(request);
	String strPageAction = WI.fillTextValue("page_action");
	
	String strSchCode = dbOP.getSchoolIndex();
 
	int iSearchResult = 0;
	int i = 0;
	boolean bolPageBreak = false;
	enrollment.Authentication authentication = new enrollment.Authentication();
	vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
 
 	vRetResult = prd.generateMiscDedLedger(dbOP, request);
 	if (vRetResult != null) {	
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = vRetResult.size()/(10*iMaxRecPerPage);	
	if((vRetResult.size() % (10*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
 %>
<body onLoad="javascript:window.print();">
<form name="form_">
   <% if (vPersonalDetails !=null && vPersonalDetails.size() > 0){ %>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="28">&nbsp;</td>
      <td height="28" colspan="2">Employee ID : <%=WI.fillTextValue("emp_id")%></td>
    </tr>
    <tr>
      <td width="4%" height="28">&nbsp;</td>
      <td height="28" colspan="2">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <%
	strTemp = (String)vPersonalDetails.elementAt(13);
	if (strTemp == null){
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
	}else{
		strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
	}
%>
      <td height="29" colspan="2"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="46%">Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%>
        </strong></td>
      <td width="50%" height="29">Employment Status : <strong><%=(String)vPersonalDetails.elementAt(16)%>
        </strong></td>
    </tr> 
    <tr>
      <td height="15" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
	<%}%>
   <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td align="center"><table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
      <tr>
        <td height="26" colspan="4" align="center" class="thinborder"><strong><%=WI.fillTextValue("deduction_name").toUpperCase()%> DEDUCTIONS</strong></td>
      </tr>
      <tr>
        <td width="7%" height="28" align="center" class="thinborder">&nbsp;</td>
        <td width="24%" align="center" class="thinborder"><font size="1"><strong>TRANSACTION DATE </strong></font></td>
        <td width="32%" align="center" class="thinborder"><font size="1"><strong>DESCRIPTION</strong></font></td>
        <td width="15%" align="center" class="thinborder"><font size="1"><strong>AMOUNT</strong></font></td>
        </tr>
			<% 
			for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=10,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			}
			else 
				bolPageBreak = false;			
			%>			
      <tr>
        <td height="25" class="thinborder" align="center"><%=iCount%>&nbsp;</td>
        <td width="24%" align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i)%></font></td>
				<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
				<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+1),true);
				strTemp = ConversionTable.replaceString(strTemp, ",","");
				strTemp2 = (String)vRetResult.elementAt(i+3);
				
				if(WI.getStrValue(strTemp2).equals("1"))					
					dTotal += Double.parseDouble(strTemp);				
				else
					dTotal -= Double.parseDouble(strTemp);				
				%>
        <td align="right" class="thinborder"><font size="1"><%=strTemp%>&nbsp;</font></td>
        </tr>
      <%} //end for loop%>
			<%if ( iNumRec >= vRetResult.size()) {%>
			<tr>
        <td height="25" colspan="2" align="right" class="thinborder">BALANCE : </td>        
        <td align="right" class="thinborder">&nbsp;</td>
        <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotal, true)%>&nbsp;</td>
      </tr>  
			<%}%>
    </table>
		</td>
  </tr>
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
