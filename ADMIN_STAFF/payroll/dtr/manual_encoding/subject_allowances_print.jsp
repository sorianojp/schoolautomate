<%@ page language="java" import="utility.*,java.util.Vector, payroll.PReDTRME" %>
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
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
TD.thinborderBOTTOMRIGHT {
	border-right: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOM{
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOMLEFTRIGHT{
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-COLA","subject_allowances.jsp");
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

//end of authenticaion code.
	Vector vRetResult = null;
	Vector vSalaryPeriod 		= null;//detail of salary period.
	
	PReDTRME prEdtrME = new PReDTRME();	
	String strPayrollPeriod  = null;
	int i = 0;
	boolean bolPageBreak = false;

	vRetResult = prEdtrME.operateOnSubjectAllowances(dbOP,request,4);
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);

	strTemp = WI.fillTextValue("sal_period_index");			
	for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
	if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
	  }//end of if condition.		  
	 }//end of for loop.	
	 	
	if (vRetResult != null) {			
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iTotalPages = vRetResult.size()/(12*iMaxRecPerPage);				
		int iIncr    = 1;
		int iPageNo = 1;
		if(vRetResult.size()%(12*iMaxRecPerPage) > 0)
			iTotalPages++;		
		for (;iNumRec < vRetResult.size();iPageNo++){	
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
	  <%
	  if((WI.fillTextValue("with_schedule")).equals("1"))
	    strTemp = "EMPLOYEES WITH ALLOWANCE";
	  else
	    strTemp = "EMPLOYEES WITHOUT ALLOWANCE";
	  %>	
    <tr> 
      <td height="25" colspan="8" align="center" class="thinborderBOTTOM"><strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td width="3%" height="24" rowspan="2" align="center" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
      <td width="9%" rowspan="2" align="center" class="thinborderBOTTOMRIGHT"><strong>EMPLOYEE ID </strong></td>
      <td width="25%" rowspan="2" align="center" class="thinborderBOTTOMRIGHT"><strong>EMPLOYEE NAME </strong></td>
      <td rowspan="2" align="center" class="thinborderBOTTOMRIGHT"><strong>DEPARTMENT/OFFICE</strong></td>
      <td colspan="2" align="center" class="thinborderBOTTOMRIGHT"><strong>WORK DURATION </strong></td>
      <td rowspan="2" align="center" class="thinborderBOTTOMRIGHT"><strong>Rate</strong></td>
      <%if(WI.fillTextValue("with_schedule").equals("1")){%>
			<%}%>			
			<%
				strTemp = "";
				if(WI.fillTextValue("selAllSave").length() > 0){
					strTemp = " checked";
				}else{
					strTemp = "";
				}
			%>
      <td rowspan="2" align="center" class="thinborderBOTTOMRIGHT"><strong>Amount</strong></td>
    </tr>
    <tr>
      <td align="center" class="thinborderBOTTOMRIGHT"><strong>Hours</strong></td>
      <td align="center" class="thinborderBOTTOMRIGHT"><strong>Minutes</strong></td>
    </tr>
		<% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=12,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			}
			else 
				bolPageBreak = false;			
		%>			
    <tr> 
      <td height="25" align="right" class="thinborderBOTTOMLEFTRIGHT"><%=iCount%>&nbsp;</td>
			<td class="thinborderBOTTOMRIGHT"><span class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></span></td>			
			<td class="thinborderBOTTOMRIGHT"><font size="1"><strong>&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),
							(String)vRetResult.elementAt(i+5), 4).toUpperCase()%></strong></font></td>
      <%if((String)vRetResult.elementAt(i + 6)== null || (String)vRetResult.elementAt(i + 7)== null){
		  	strTemp = "";			
		  }else{
		  	strTemp = " - ";
		  }
		%>							
			<td width="31%" class="thinborderBOTTOMRIGHT"><span class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"")%> </span></td>
		<%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 8);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>			
			<td width="7%" align="right" class="thinborderBOTTOMRIGHT"><%=strTemp%>&nbsp;</td>
		<%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 11);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>						
			<td width="8%" align="right" class="thinborderBOTTOMRIGHT"><%=strTemp%>&nbsp;</td>
		<%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 9);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
			else
				strTemp = CommonUtil.formatFloat(Double.parseDouble(strTemp),2);
		%>						
			<td width="8%" align="right" class="thinborderBOTTOMRIGHT"><%=strTemp%>&nbsp;</td>
		<%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 10);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
			else
				strTemp = CommonUtil.formatFloat(Double.parseDouble(strTemp),2);
		%>				
			<td width="9%" align="right" class="thinborderBOTTOMRIGHT"><%=strTemp%>&nbsp;</td>
    </tr>
    <%}// end for loop%>
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
