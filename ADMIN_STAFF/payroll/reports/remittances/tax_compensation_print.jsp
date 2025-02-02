<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Tax Withheld printing</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
table.thinborder {
	border-top: solid 1px #000000;
	border-right: solid 1px #000000;
}

TD.thinborderBOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

TD.thinborderBOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderLEFT {
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderLEFTRIGHT {
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

TD.thinborderTOP {
	border-top: solid 1px #000000;	
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<body onLoad="javascript:window.print();">
<form name="form_" method="post" action="./tax_compensation_print.jsp">
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;
	int iSearchResult = 0;

//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","tax_compensation.jsp");

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
														"tax_compensation.jsp");
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

Vector vRetResult = null;
PRRemittance PRRemit = new PRRemittance(request);
Vector vEmployerInfo = null;
double dTemp  = 0d;
boolean bolNextEmp = false;
boolean bolIncremented = false;
int iMonthOf = 0;

String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};
					  
int i = 0;
String strMonth = null;
String strYear = WI.fillTextValue("year_of");

double dPageTotal15   = 0d;
double dPageTotal31   = 0d;
double dGrandTotal15  = 0d;
double dGrandTotal31  = 0d;
double dRowTotal = 0d;
double dGrandTotal = 0d;

boolean bolPageBreak  = false;
String strEmployerTINNo = null;

  vRetResult = PRRemit.getWithholdingTaxCompensation(dbOP);
	if(vRetResult != null && vRetResult.size() > 0){
		vEmployerInfo = (Vector)vRetResult.elementAt(0);
	
		i = 0; int iPage = 1; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
			

		int iNumRec = 1;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = vRetResult.size()/(8*iMaxRecPerPage);	
	    if(vRetResult.size() % (8*iMaxRecPerPage) > 0) ++iTotalPages;

	
	if(vEmployerInfo == null){
		strErrMsg = PRRemit.getErrMsg();
	}else{	
		strEmployerTINNo = (String)vEmployerInfo.elementAt(7);		
	}


if(WI.fillTextValue("month_of").length() > 0){
	iMonthOf = Integer.parseInt(WI.fillTextValue("month_of")) + 1;
	strMonth = Integer.toString(iMonthOf);
}
  	int iEmpCtr = 1;	
	 for (;iNumRec < vRetResult.size();iPage++){
	 	dPageTotal15 =0d;	
		dPageTotal31 =0d;	
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="5"><div align="center"><font size="2"><strong><%if(vEmployerInfo != null){
					strTemp = (String) vEmployerInfo.elementAt(12);
					strTemp += "<br>" + (String) vEmployerInfo.elementAt(3) + "<br>";
				%>
        <%=strTemp%><br>

        <%}else{%>
        <%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <%}%>
      </font></div></td>
    </tr>
    <tr >
      <td height="18" colspan="5">&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="4"><div align="center"><strong><font color="#000000" ><strong>WITHHOLDING TAX</strong></font> COMPENSATION <br>
			<%if(strSchCode.startsWith("WUP")  && strEmployerTINNo != null && strEmployerTINNo.length() > 0  ){//wup wants to display tin number%>
				Employer TIN No. : <%=strEmployerTINNo%> <br />
		    <%}//end of WUP%>
          <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></div></td>
  </tr>
  <tr>
    <td colspan="4"><div align="right">&nbsp;</div></td>
  </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">	
  <tr>
  
   <td class="thinborderBOTTOMLEFT" width="4%">&nbsp;</td>
  	<td width="12%" height="19" align="center" class="thinborderBOTTOMLEFT">TIN</td>
    <td width="12%" align="center" class="thinborderBOTTOMLEFT">EMPLOYEE ID </td>
    <td width="34%" height="19" align="center" class="thinborderBOTTOMLEFT"><strong>NAME OF &nbsp;EMPLOYEES</strong></td>
    <td align="center" class="thinborderBOTTOMLEFT"><strong>15</strong></td>
    <td align="center" class="thinborderBOTTOMLEFT"><strong>31</strong></td>
		<%if(WI.fillTextValue("show_total").equals("1")){%>
    <td width="20%" align="center" class="thinborderBOTTOMLEFT"><strong>TOTAL</strong></td>
		<%}%>
  </tr>
  
      <% 
		for(iCount = 1; iNumRec<vRetResult.size(); ++iIncr, ++iCount){
		dRowTotal = 0d;
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	   %>
  
    <tr>
	 <td class="thinborderBOTTOMLEFT" width="4%"><%=iEmpCtr++%></td>	
		<td class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5),"")%></td>
	    <td class="thinborderBOTTOMLEFT">&nbsp;<%=vRetResult.elementAt(i+6)%></td>
      <td height="23" class="thinborderBOTTOMLEFT">&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+1)).toUpperCase(), (String)vRetResult.elementAt(i+2),
								((String)vRetResult.elementAt(i+3)).toUpperCase(), 4)%></td>
								
	<%  
	  for(; iNumRec < vRetResult.size();){		
	  	bolNextEmp = false;
		bolIncremented = false;
	%>
	  <%
	  if(ConversionTable.compareDate((String)vRetResult.elementAt(iNumRec+7),strMonth +"/15/"+strYear) < 1){
		  	strTemp = (String)vRetResult.elementAt(iNumRec+4);
			
			iNumRec = iNumRec + 8;			
			bolIncremented = true;
		}else
			strTemp = "";
      
	  strTemp = CommonUtil.formatFloat(WI.getStrValue(strTemp,"0"),true);			
	  dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
	  dPageTotal15 += dTemp;			
		dRowTotal = dTemp;
	  %>
	  <td width="15%" align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>	  
	  <% 	
		 dTemp = 0d;
		 if(iNumRec < vRetResult.size()){
			if(iNumRec > 1 && !((String)vRetResult.elementAt(iNumRec)).equals((String)vRetResult.elementAt(iNumRec-8)))
				bolNextEmp = true;	
						
			if(!bolNextEmp){
				if(ConversionTable.compareDate((String)vRetResult.elementAt(iNumRec+7),strMonth +"/31/"+strYear) < 1){
					strTemp = (String)vRetResult.elementAt(iNumRec+4);
					iNumRec = iNumRec + 8;
					bolIncremented = true;
				} else
					strTemp = "";
			}else{
					if(!bolIncremented){
					strTemp = (String)vRetResult.elementAt(iNumRec+4);
					iNumRec = iNumRec + 8;
				bolIncremented = true;			
				}else{
					strTemp = "";
				}
			 }      		
			 strTemp = CommonUtil.formatFloat(WI.getStrValue(strTemp,"0"),true);
			 dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
			 dPageTotal31 += dTemp;	  
		 }else{
		 	strTemp = "";
		 }		 
		 dRowTotal += dTemp;
		 dGrandTotal += dRowTotal;
	  %>
	  <td width="15%" align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(WI.getStrValue(strTemp,"0"),true)%>&nbsp;</td>
		<%if(WI.fillTextValue("show_total").equals("1")){%>
	  <td width="20%" align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dRowTotal,true)%>&nbsp;</td>
		<%}%>
	  <%
	  	 break;
	  }%>	  
    </tr>
  <% if(!bolIncremented){
  		break;
		}
  }// outer for loop%>  
  <tr>
   
    <td align="right" class="thinborderBOTTOMLEFT" colspan="4" height="23">Page Total&nbsp;: </td>
	<%
		dGrandTotal15 += dPageTotal15;
		dGrandTotal31 += dPageTotal31;
	%>	
    <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dPageTotal15,true)%>&nbsp;</td>
    <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dPageTotal31,true)%>&nbsp;</td>
		<%if(WI.fillTextValue("show_total").equals("1")){%>
    <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dPageTotal15 + dPageTotal31,true)%></td>
		<%}%>
  </tr>
 
  <%if ( iNumRec >= vRetResult.size()){%>
  <tr>
    <td align="right" class="thinborderBOTTOMLEFT" colspan="4" height="40"><strong>Grand Total&nbsp;:</strong> </td>
	<%if ( iNumRec >= vRetResult.size())
	  	strTemp = CommonUtil.formatFloat(dGrandTotal15,true);
	  else
	  	strTemp = "-";
	%>
    <td align="right" class="thinborderBOTTOMLEFT"><strong><%=strTemp%></strong>&nbsp;</td>
	<%if ( iNumRec >= vRetResult.size())
	  	strTemp = CommonUtil.formatFloat(dGrandTotal31,true);
	  else
	  	strTemp = "-";
	%>	
    <td align="right" class="thinborderBOTTOMLEFT"><strong><%=strTemp%></strong>&nbsp;</td>
	<%if ( iNumRec >= vRetResult.size())
	  	strTemp = CommonUtil.formatFloat(dGrandTotal,true);
	  else
	  	strTemp = "-";
	%>			
		<%if(WI.fillTextValue("show_total").equals("1")){%>
    <td align="right" class="thinborderBOTTOMLEFT"><strong><%=strTemp%></strong>&nbsp;</td>
		<%}%>
  </tr>
  <%}//end of grand total%>
</table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>