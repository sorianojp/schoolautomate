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
<title>Tax Withheld</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.thinborderBOTTOMLEFTx {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

TD.thinborderBOTTOMLEFTRIGHTx {
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
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}


function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}

</script>

<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance" %>

<body onLoad="javascript:window.print();" class="bgDynamic">
<form name="form_" method="post" action="./tax_compensation_print2.jsp">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	boolean bolHasTeam = false;

//add security here.
%>
	
<% 

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-Remittances-Tax Compensation","tax_compensation_print2.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
														"tax_compensation_print2.jsp");
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
boolean bolNextEmp = false;
int iMonthOf = 0;

String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};
					  
int i = 0;
String strMonth = null;
String strYear = WI.fillTextValue("year_of");
boolean bolIncremented = false;
double dTemp = 0d;
double dRowTotal = 0d;

if(WI.fillTextValue("searchEmployee").equals("1")){
  vRetResult = PRRemit.getWithholdingTaxCompensation2(dbOP);
	if(vRetResult == null){
		strErrMsg = PRRemit.getErrMsg();
	}else{	
		iSearchResult = PRRemit.getSearchCount();
	}
}

if(WI.fillTextValue("month_of").length() > 0){
	iMonthOf = Integer.parseInt(WI.fillTextValue("month_of")) + 1;
	strMonth = Integer.toString(iMonthOf);
}

if(strErrMsg == null) 
strErrMsg = "";
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL : WITHHOLDING TAX II PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
		<td height="23" colspan="3"><font size="1"><a href="./remittances_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
    </tr>
	<tr> 
		<td height="23" colspan="3"><strong><%=strErrMsg%></strong></td>
	</tr>
  
<%if (vRetResult != null && vRetResult.size() > 0 ){%>  

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="5">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="5"><div align="center"><strong><font color="#000000" ><strong>WITHHOLDING TAX</strong></font> COMPENSATION <br>
          <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></div></td>
  </tr>
  <tr>
    <td colspan="5" class="thinborderBOTTOM">&nbsp;</td>
  </tr>
  </table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
  <tr>
    <td >&nbsp;</td>
    <td height="19" >&nbsp;</td>
	<td height="23" >&nbsp;</td>
    <td align="right" >15th&nbsp;&nbsp;&nbsp;</td>
    <td align="right" >30th&nbsp;&nbsp;&nbsp;</td>
    <td align="right" >TOTAL&nbsp;</td>
  </tr>
  
  <%
	int iCount = 1;
	String strDept = "";
	String strTemp1 = "";
	String strNxtDept = "";
	
	double d15th = 0d;
	double d30th = 0d;
	double dTotal = 0d;
	
	double dTotal15th = 0d;
	double dTotal30th = 0d;
	double dTotal1530th = 0d;
	
	double dGrandTotal = 0d;
	double dGrandTotal15th = 0d;
	double dGrandTotal30th = 0d;
	
	int lastidx = 0;
	int iRetResultSize = vRetResult.size();
		
  for(i=1; i<iRetResultSize;iCount++){
	strDept = (String)vRetResult.elementAt(i+8);
	
	for(int ii=1; ii<iRetResultSize; ii+=9){
		if( iRetResultSize >= (ii+17+lastidx) && !strDept.equals((vRetResult.elementAt(ii+17+lastidx)+"")) ){
			strNxtDept = (String)vRetResult.elementAt((ii+17+lastidx));
			break;
		}
		lastidx+=9;
	}
	
	dTemp = 0d;	
	strDept = (strDept == null ? "NOT DEFINED DEPT." : strDept);
  %>	
	<%if( !strDept.equals(strTemp1) ){
		strTemp1 = strDept;
	%>
	<tr height="30">
		<td colspan="5">&nbsp;
			<%=strDept%>
		</td>
	</tr>
	<%}%>	
    <tr>
		<td>&nbsp;</td>
		<!-- NAME -->
		<td height="23" class="thinborderBOTTOMLEFT">&nbsp;
			<%=WI.formatName(((String)vRetResult.elementAt(i+1)).toUpperCase(), (String)vRetResult.elementAt(i+2),
				((String)vRetResult.elementAt(i+3)).toUpperCase(), 4)%>
		</td>
		<!-- ID NUMBER -->
		<td height="23" class="thinborderBOTTOMLEFT">&nbsp;
			<%=(String)vRetResult.elementAt(i+6)%>
		</td>
	<%  
	  for(; i < vRetResult.size();){	
	  	bolNextEmp = false;
		bolIncremented = false;
	%>
	  <% 
	  if(ConversionTable.compareDate((String)vRetResult.elementAt(i+7),strMonth +"/15/"+strYear) < 1){
		 strTemp = (String)vRetResult.elementAt(i+4);
		 i = i + 9;			 
		 bolIncremented = true;
	  }else{
		 strTemp = "";
		}
		strTemp = WI.getStrValue(strTemp,"0");
		dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
		d15th = Double.parseDouble(CommonUtil.formatFloat(strTemp,true));
	  %>
	  <!-- 15th -->
		<td align="right" class=""><%=d15th%>&nbsp;&nbsp;</td>	  
	  <% 
		if(i < vRetResult.size()){
			if(i > 2 && !((String)vRetResult.elementAt(i)).equals((String)vRetResult.elementAt(i-9)))
			  bolNextEmp = true;
			
			if(!bolNextEmp){
				if(ConversionTable.compareDate((String)vRetResult.elementAt(i+7),strMonth +"/31/"+strYear) < 1){
					strTemp = (String)vRetResult.elementAt(i+4);
					i = i + 9;
					bolIncremented = true;
				}else{
					strTemp = "";
				}
			}else{
				if(!bolIncremented){
					strTemp = (String)vRetResult.elementAt(i+4);
					i = i + 9;
					bolIncremented = true;			
				}else{
					strTemp = "";	
				}
			}
		}else{
			strTemp = "";
		}	
		
		strTemp = WI.getStrValue(strTemp,"0");
		dTemp += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
		d30th = Double.parseDouble(CommonUtil.formatFloat(strTemp,true));
		dTotal = d15th + d30th;
		dTotal15th += d15th;
		dTotal30th += d30th;
		dTotal1530th += dTotal;
		
		dGrandTotal += dTotal;
		dGrandTotal15th += d15th;
		dGrandTotal30th += d30th;
	  %>
	  <!-- 30th -->
		<td align="right" class="thinborderBOTTOMLEFT"><%=d30th%>&nbsp;&nbsp;</td>	  
	  <!-- TOTAL -->
		<td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotal,true)%>&nbsp;&nbsp;</td>	    
    </tr>	
	<%
		 break;
		}// inner for loop
	%>	
	
	<%if( !strDept.equals(strNxtDept) || i>= iRetResultSize ){%>
	<tr height="30" >
		<td colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="2">TOTAL =====> </font></strong></td>		
		<td align="right"><strong><font size="2"><%=CommonUtil.formatFloat(dTotal15th,true)%>&nbsp;&nbsp;</font></td>
		<td align="right"><strong><font size="2"><%=CommonUtil.formatFloat(dTotal30th,true)%>&nbsp;&nbsp;</font></td>
		<td align="right"><strong><font size="2"><%=CommonUtil.formatFloat(dTotal1530th,true)%>&nbsp;&nbsp;</font></td>
	</tr>
	<%
		dTotal15th = 0d;
		dTotal30th = 0d;
		dTotal1530th = 0d;
	}%>
  <% if(!bolIncremented){
  		break;
	}
  }// outer for loop%>
  
	<tr height="50" >
		<td colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3">GRAND TOTAL =====> </font></strong></td>		
		<td align="right"><strong><font size="3"><%=CommonUtil.formatFloat(dGrandTotal15th,true)%>&nbsp;&nbsp;</font></td>
		<td align="right"><strong><font size="3"><%=CommonUtil.formatFloat(dGrandTotal30th,true)%>&nbsp;&nbsp;</font></td>
		<td align="right"><strong><font size="3"><%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;&nbsp;</font></td>
	</tr>
  
  <tr>
    <td width="4%">&nbsp;</td>
    <td width="43%">&nbsp;</td>
    <td width="15%">&nbsp;</td>
    <td width="13%">&nbsp;</td>
    <%if(WI.fillTextValue("show_total").equals("1")){%>
		<td width="13%">&nbsp;</td>
		<%}%>
  </tr>
</table>
<%} // if (vRetResult != null && vRetResult.size() > 0 )%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
  <tr>
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A">
    <td width="50%" height="25" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>