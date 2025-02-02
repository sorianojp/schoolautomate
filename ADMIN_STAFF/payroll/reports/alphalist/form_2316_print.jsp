<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRTaxReport" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Form 2316</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css"> 

<style type="text/css">
td {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td.answer{
	font-family: Arial, Helvetica, sans-serif;
	font-size: 12px;
}

</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;

try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions","emp_prev_salary.jsp");

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
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
/*
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"emp_prev_salary.jsp");
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
*/
	PRTaxReport prEmpInfo = new PRTaxReport();
	Vector vEmpInfo = null;
	Vector vEditInfo = null;
	Vector vDepInfo = null;
	Vector vEmployer  = null;
	Vector vPrevEmployer = null;
	String strEmpID = null;
	int iDep = 0;
	double dTemp = 0d;
	boolean bolIsMWE = false;
	Vector vDepBday = new Vector();
	String[] astrExemptionName    = {"Zero(No Exemption)", "Single","Head of Family", "Head of Family 1 Dependent (HF1)", 
																	"Head of Family 2 Dependents (HF2)","Head of Family 3 Dependents (HF3)", 
																	"Head of Family 4 Dependents (HF4)", "Married Employed", 																	 
																	 "Married Employed 1 Dependent (ME1)", "Married Employed 2 Dependents (ME2)",
																	 "Married Employed 3 Dependents (ME3)", "Married Employed 4 Dependents (ME4)"};
	String[] astrExemptionVal     = {"0","1","2","21","22","23","24","3","31","32","33","34"};

	vEmpInfo = prEmpInfo.getPersonalTaxInfo(dbOP, request, null);
 	if(vEmpInfo == null)
		strErrMsg = prEmpInfo.getErrMsg();
	else{
		vDepInfo = (Vector)vEmpInfo.elementAt(9);
		vEmployer = (Vector)vEmpInfo.elementAt(10);
		vEditInfo = prEmpInfo.operateOnEmployee2316(dbOP, request, 4);
		vPrevEmployer = prEmpInfo.getPreviousEmployerInfo(dbOP, request, null, WI.fillTextValue("year_of"));
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(14);
			if(strTemp.equals("1"))
				bolIsMWE = true;
		}
  }
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <img src="images/arrow_white_bg.jpg" /><font face="arial" style="font-size: 8pt"><b>DLN:</b></font> 
<table width="100%" height="70" border="1" cellpadding="0" cellspacing="0">
<tr>
	<td colspan="2">
	<table border="0" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="9%" align="center"><img src="images/2316_logo.jpg" width="57" height="52"/></td>
		<td width="19%">	
			Republika ng Pilipinas<br/>
			Kagawaran ng Pananalapi<br/>
		  Kawanihan ng Rentas Internas</td>
		<td width="53%" align="center">
		<font size="5">
		Certificate of Compensation<br/>
		Payment/Tax Withheld</font></td>
		<td width="19%">
		BIR Form No.<br/>
		<font size="7"><b>2316</b></font><br/>		</td>
	</tr>
	<tr>
		<td colspan="3"><font size="1">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;For Compensation Payment With or Without Tax Withheld</font></td>
		<td>
			July 2008 (ENCS)		</td>
	</tr>
	</table>	</td>
</tr>
<tr>
	<td colspan="2">
		Fill in all applicable spaces. Mark all appropriate boxes with an "X"</td>
</tr>
<tr>
	<td bgcolor="#999999" width="50%">
	<table width="46%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="64%">
		1 For the Year<br/>
		&nbsp;&nbsp;&nbsp;&nbsp;(YYYY)		</td>
		<td width="8%">
		<img src="images/arrow.jpg" width="6" height="7" />		</td>
	  <td width="28%" ><table width="100%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
         <td align="center" style="font-size:13px"><%=WI.fillTextValue("year_of")%></td>
      </tr>
    </table></td>
	</tr>
	</table></td>
	<td width="50%" bgcolor="#999999">
		<table width="94%" border="0" cellpadding="0" cellspacing="0">
		<tr>
		<td width="33%">
		2 For the Period<br/>
		&nbsp;&nbsp;&nbsp;&nbsp;<img src="images/arrow.jpg" width="6" height="7" /> From &nbsp;&nbsp;&nbsp;&nbsp;(MM/DD)		</td>
		<td width="20%" align="center">
		<table width="100%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(2);

				strTemp = WI.getStrValue(strTemp, "0101");
			%>			
        <td align="center" style="font-size:13px"><%=strTemp%></td>
        </tr>
    </table>						</td>
		<td valign="bottom" align="right" width="27%">
		To&nbsp;&nbsp;&nbsp;(MM/DD)		</td>
		<td width="20%" align="center"><table width="100%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
        <%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(3);

				strTemp = WI.getStrValue(strTemp, "1231");
			%>
        <td align="center" style="font-size:13px"><%=strTemp%></td>
      </tr>
    </table>					</td>
		</tr>
		</table>	</td>
</tr>
<tr>
	<td>
		<b>Part I &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Employee Information</b>	</td>
	<td nowrap="nowrap">
		<b>Part IV-B <font style="font-size:7px;font-family:Verdana, Arial, Helvetica, sans-serif">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Details of Compensation Income and Tax Withheld from Present Employer</font></b></td>
</tr>
<tr valign="top" bgcolor="#999999">
	<td height="28">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="29%">
		3 Taxpayer<br/>
		&nbsp;&nbsp;&nbsp;Identification No.		</td>
		<td width="7%"><img src="images/arrow.jpg" width="6" height="7" /></td>
		<%
			if(vEmpInfo != null && vEmpInfo.size() > 0){
				strTemp = (String)vEmpInfo.elementAt(1);
			}else{
				strTemp = "";
			}
		%>
		<td width="64%"><table width="100%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
        <td align="center" style="font-size:13px"><%=WI.getStrValue(strTemp)%></td>
      </tr>
    </table></td>
	</tr>
	</table>	</td>
	<td rowspan="20">
 	<table width="99%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="12"></td>
			<td></td>
			<td></td>
			<td align="center">Amount</td>
		</tr>
		<tr>
			<td height="23" valign="top"><b>A</b></td>
			<td colspan="3" valign="top"><b>NON-TAXABLE/EXEMPT COMPENSATION INCOME</b></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="39">32</td>
			<td width="47%">
			Basic Salary/<br/>
		    Statutory Minimun Wage<br/>
			Minimun Wage Earner (MWE)</td>
			<td width="4%" align="right">32</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(31);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="30">33</td>
			<td width="47%">
			Holiday Pay (MWE)</td>
			<td width="4%" align="right">33</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(32);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="30">34</td>
			<td width="47%">
			Overtime Pay (MWE)</td>
			<td width="4%" align="right">34</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(33);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="30">35</td>
			<td width="47%">
			Night Shift Differential (MWE)</td>
			<td width="4%" align="right">35</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(34);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="30">36</td>
			<td width="47%">
			Hazard Pay (MWE)</td>
			<td width="4%" align="right">36</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(35);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="30">37</td>
			<td width="47%">
			13th Month Pay<br/>
			and Other Benefits</td>
			<td width="4%" align="right">37</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(36);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="30">38</td>
			<td width="47%">
			De Minimis Benefits</td>
			<td width="4%" align="right">38</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(37);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%">39</td>
			<td width="47%">
			SSS, GSIS, PHIC & Pag-ibig<br/>
			Contributions, & Union Dues<br/>
			<sup><i>(Employee share only)</i></sup></td>
			<td width="4%" align="right">39</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(38);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="33">40</td>
			<td width="47%">
			Salaries & Other Forms of<br/>
			compensation</td>
			<td width="4%" align="right">40</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(39);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="30">41</td>
			<td width="47%">
			Total Non-Taxable/Exempt<br/>
			Compensation Income</td>
			<td width="4%" align="right">41</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(20);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td height="25"><b>B</b></td>
			<td colspan="3"><b>TAXABLE COMPENSATION INCOME<br />REGULAR</b></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="34">42</td>
			<td width="47%">
			Basic Salary</td>
			<td width="4%" align="right">42</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(40);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>		
		<tr valign="top">
			<td width="4%" height="40">43</td>
			<td width="47%">
			Representation</td>
			<td width="4%" align="right">43</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(41);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>		
		<tr valign="top">
			<td width="4%" height="40">44</td>
			<td width="47%">
			Transportation</td>
			<td width="4%" align="right">44</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(42);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="33">45</td>
			<td width="47%">
			Cost of Living Allowance</td>
			<td width="4%" align="right">45</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(43);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="34">46</td>
			<td width="47%">Fixed Housing Allowance</td>
			<td width="4%" align="right">46</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(44);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td><b>47</b></td>
			<td colspan="3">Others (Specify)</td>
		</tr>
		<tr valign="top">
			<td width="4%" height="34">47A</td>
			<td width="47%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(45);
						else
							strTemp = "";
						strTemp = WI.getStrValue(strTemp);
					%>
          <td style="font-size:12px">&nbsp;<%=strTemp%></td>
        </tr>
      </table></td>
			<td width="4%" align="right">47A</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(46);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="33">47B</td>
			<td width="47%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(47);
						else	
							strTemp = "";
						strTemp = WI.getStrValue(strTemp);
					%>
          <td style="font-size:12px">&nbsp;<%=strTemp%></td>
        </tr>
      </table></td>
			<td width="4%" align="right">47B</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(48);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="33">48</td>
			<td width="47%">
			Commission</td>
			<td width="4%" align="right">48</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(49);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="29">49</td>
			<td width="47%">
			Profit Sharing</td>
			<td width="4%" align="right">49</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(50);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="28">50</td>
			<td width="47%">
			Fees Including Director's<br/>Fees</td>
			<td width="4%" align="right">50</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(51);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="26">51</td>
			<td width="47%">
			Taxable 13th Month Pay<br/>and Other Benefits</td>
			<td width="4%" align="right">51</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(52);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="29">52</td>
			<td width="47%">
			Hazard Pay</td>
			<td width="4%" align="right">52</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(53);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%">53</td>
			<td width="47%">
			Overtime Pay</td>
			<td width="4%" align="right">53</td>
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(54);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
		  <td height="15">&nbsp;</td>
		  <td colspan="3"><strong>SUPPLEMENTARY</strong></td>
		  </tr>
		<tr valign="top">
			<td height="15"><b>54</b></td>
			<td colspan="3">Others (Specify)</td>
		</tr>
		<tr valign="top">
			<td width="4%" height="33">54A</td> 
			<td width="47%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(55);
						else	
							strTemp = "";
						strTemp = WI.getStrValue(strTemp);
					%>
          <td style="font-size:12px">&nbsp;<%=strTemp%></td>
        </tr>
      </table></td>
			<td width="4%" align="right">54A</td> 
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(56);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%" height="29">54B</td> 
			<td width="47%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(57);
						else	
							strTemp = "";
						strTemp = WI.getStrValue(strTemp);
					%>
          <td style="font-size:12px">&nbsp;<%=strTemp%></td>
        </tr>
      </table></td>
			<td width="4%" align="right">54B</td> 
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(58);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="4%">55</td>
			<td width="47%">
			Total Taxable Compensation<br/>Income</td>
			<td width="4%" align="right">55</td> 
			<td width="45%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(21);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
	</table>	
	
 </td>
</tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="2">4 Employee's Name (Last Name, First Name, Middle Name)</td>
		<td width="19%">5 RDO Code</td>
	</tr>
	<tr>
		<td width="2%">
		<img src="images/arrow.jpg" width="6" height="7" /></td>
 		<td width="79%"><table width="98%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
			<%
				if(vEmpInfo != null && vEmpInfo.size() > 0){
					strTemp = WI.formatName((String)vEmpInfo.elementAt(2), (String)vEmpInfo.elementAt(3), (String)vEmpInfo.elementAt(4), 5);
					//for(int o = 1; o < 12; o++)
					//	System.out.println("o - " + WI.formatName((String)vEmpInfo.elementAt(2), (String)vEmpInfo.elementAt(3), (String)vEmpInfo.elementAt(4), o));
				}else{
					strTemp = "";
				}
			%>
				<td style="font-size:10px"><%=strTemp%></td>
      </tr>
    </table></td>
 		<td><table width="94%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(4);

				strTemp = WI.getStrValue(strTemp);
			%>			
        <td align="center" style="font-size:12px"><%=strTemp%></td>
        </tr>
    </table></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="2">6 Registered Address</td>
		<td width="19%">6A Zip Code</td>
	</tr>
	<tr>
		<td width="2%">
		<img src="images/arrow.jpg" width="6" height="7" /></td>
		<td width="79%"><table width="98%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
        <%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(5);

				strTemp = WI.getStrValue(strTemp);
			%>
        <td style="font-size:10px"><%=strTemp%></td>
      </tr>
    </table></td>
		<td><table width="94%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
        <%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(6);

				strTemp = WI.getStrValue(strTemp);
			%>
        <td align="center" style="font-size:12px"><%=strTemp%></td>
      </tr>
    </table></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="2">6B Local Home Address</td>
		<td width="19%">6C Zip Code</td>
	</tr>
	<tr>
		<td width="2%">
		<img src="images/arrow.jpg" width="6" height="7" /></td>
		<td width="79%"><table width="98%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
        <%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(7);

				strTemp = WI.getStrValue(strTemp);
			%>
        <td style="font-size:10px"><%=strTemp%></td>
      </tr>
    </table></td>
		<td><table width="94%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
        <%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(8);

				strTemp = WI.getStrValue(strTemp);
			%>
        <td align="center" style="font-size:12px"><%=strTemp%></td>
      </tr>
    </table></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="2">6D Foreign Address</td>
		<td width="19%">6E Zip Code</td>
	</tr>
	<tr>
		<td width="2%">
		<img src="images/arrow.jpg" width="6" height="7" /></td>
		<td width="79%"><table width="98%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
        <%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(9);

				strTemp = WI.getStrValue(strTemp);
			%>
        <td style="font-size:10px"><%=strTemp%></td>
      </tr>
    </table></td>
		<td><table width="94%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
        <%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(10);

				strTemp = WI.getStrValue(strTemp);
			%>
        <td align="center" style="font-size:12px"><%=strTemp%></td>
      </tr>
    </table></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="52%">7 Date of Birth (MM/DD/YYYY)<br/>
        <table width="50%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr>
		<%
			if(vEmpInfo != null && vEmpInfo.size() > 0){
				strTemp = (String)vEmpInfo.elementAt(5);
			}else{
				strTemp = "";
			}
			strTemp = ConversionTable.replaceString(strTemp, "/"," / ");
		%>
      <td style="font-size:13px">&nbsp;<%=strTemp%></td>
    </tr>
  </table></td>
      <td width="48%">8 Telephone Number<br/>
        <table width="70%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr>
			<%
				if(vEmpInfo != null && vEmpInfo.size() > 0){
					strTemp = (String)vEmpInfo.elementAt(6);
				}else{
					strTemp = "";
				}
			%>
			<td style="font-size:13px">&nbsp;<%=WI.getStrValue(strTemp)%></td>
    </tr>
  </table></td>
    </tr>
  </table></td>
    </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td>9 Exemption Status</td>
	</tr>
	<tr> 
		  <td align="center"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
		<%
		strTemp = "";
			if(vEditInfo != null && vEditInfo.size() > 0){
				strTemp = (String)vEditInfo.elementAt(67);
			} 
		strTemp = WI.getStrValue(strTemp);

 		if(strTemp.startsWith("0")){
			strTemp = "<img src='images/status_box.jpg' width='20' height='15' />";
			strTemp2 = "<img src='images/status_box.jpg' width='20' height='15' />";
		}else if(strTemp.startsWith("1")){ 
			strTemp2 = "<img src='images/status_box.jpg' width='20' height='15' />";
			strTemp = "<img src='images/x_status_box.jpg' width='20' height='15' />";
		}else{
			strTemp2 = "<img src='images/x_status_box.jpg' width='20' height='15' />";
			strTemp = "<img src='images/status_box.jpg' width='20' height='15' />";
		}%>	
          <td width="34%" align="right"><%=strTemp%></td>
          <td width="25%">Single</td>
          <td width="8%" align="right"><%=strTemp2%></td>
          <td width="33%">Married</td>
        </tr>
      </table></td>
		</tr>
	<tr>
		<td nowrap="nowrap">9A Is the wife claiming the additional exemption for qualified dependent children?</td>
	</tr>
	<tr>
	  <td align="right"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
				<%
					strTemp = "";
						if(vEditInfo != null && vEditInfo.size() > 0){
							strTemp = (String)vEditInfo.elementAt(11);
						} 
					strTemp = WI.getStrValue(strTemp);
					//System.out.println("strTemp " + strTemp);

					if(strTemp.startsWith("1")){ 
						strTemp2 = "<img src='images/status_box.jpg' width='20' height='15' />";
						strTemp = "<img src='images/x_status_box.jpg' width='20' height='15' />";
					}else{
						strTemp2 = "<img src='images/x_status_box.jpg' width='20' height='15' />";
						strTemp = "<img src='images/status_box.jpg' width='20' height='15' />";
					}
				%>
        <td width="34%" align="right"><%=strTemp%></td>
        <td width="25%">Yes</td>
        <td width="8%" align="right"><%=strTemp2%></td>
        <td width="33%">No</td>
      </tr>
    </table></td>
	  </tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="61%">10 Name of Qualified Dependent Children</td>
			<td width="39%">11 Date of Birth (MM/DD/YYYY)</td>
		</tr>
		<tr>
			<td>
				<table width="98%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
          <%if(vDepInfo != null){
						while(vDepInfo.size() > 0){
							strTemp = WI.formatName((String)vDepInfo.remove(0), (String)vDepInfo.remove(0), (String)vDepInfo.remove(0), 5);
							vDepBday.addElement((String)vDepInfo.remove(0));
							iDep++;
					%>
					<tr >
            <td style="font-size:10px" height="18" class="thinborder"><%=strTemp%></td>
          </tr>
					<%
						if(iDep == 4)
							break;
						}
					}%>
					<%while(iDep < 4){
						iDep ++;
						%>
					<tr>
            <td style="font-size:10px" class="thinborder" height="18">&nbsp;</td>
          </tr>
					<%}%>
        </table>
				</td>			
			<td><table width="94%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
        <%
					iDep = 0;
				if(vDepBday != null){
						while(vDepBday.size() > 0){
							strTemp = (String)vDepBday.remove(0);
							iDep++;
							strTemp = ConversionTable.replaceString(strTemp, "/", " / ");
					%>
        <tr>
          <td style="font-size:10px" height="18" class="thinborder"><%=strTemp%></td>
        </tr>
        <%
						if(iDep == 4)
							break;
						}
					}%>
        <%while(iDep < 4){
						iDep ++;
						%>
        <tr>
          <td style="font-size:10px" class="thinborder" height="18">&nbsp;</td>
        </tr>
        <%}%>
      </table></td>
		</tr>
	  </table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr valign="top">
			<td width="61%" height="21">12 Statutory Minimun Wage rate per day</td>
			<td width="5%">12</td>
			<td width="34%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(12);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(Double.parseDouble(strTemp) == 0d)
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="61%">13 Statutory Minimun Wage rate per month</td>
			<td width="5%">13</td>
			<td width="34%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(13);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr valign="top">
			<td width="3%">14</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){
					strTemp = (String)vEditInfo.elementAt(14);
				}
 
 					strTemp = WI.getStrValue(strTemp);
					if(strTemp.equals("1")){ 						
						strTemp2 = "<img src='images/x_status_box.jpg' width='15' height='15' />";
					}else{
 						strTemp2 = "<img src='images/status_box.jpg' width='15' height='15' />";
					}
				%>
			<td width="7%" align="center" valign="middle"><%=strTemp2%></td>
			<td width="90%">Minimun Wage Earner whose compensation is exempt from<br/>
		  withholding tax and not subject to income tax</td>
		</tr>
	  </table>	</td>
  </tr>
<tr>
	<td>
	<b>Part II &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Employer Information (Present)</b>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="25%">
		15 Taxpayer<br/>
		&nbsp;&nbsp;&nbsp;Identification No.		</td>
		<td width="3%"><img src="images/arrow.jpg" width="6" height="7" /></td>
		<td width="72%">
			<table width="70%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
				<%
				if(vEmployer != null && vEmployer.size() > 0)
					strTemp = (String)vEmployer.elementAt(6);
				else
					strTemp = "";
				strTemp = WI.getStrValue(strTemp);
				%>
			<td style="font-size:12px">&nbsp;<%=strTemp%></td>
      </tr>
    </table></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="2">16 Employer's Name</td>
	</tr>
	<tr>
		<td width="2%">
		<img src="images/arrow.jpg" width="6" height="7" /></td>
	  <td width="98%"><table width="98%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
        <%
				if(vEmployer != null && vEmployer.size() > 0)
					strTemp = (String)vEmployer.elementAt(1);
				else
					strTemp = "";
				strTemp = WI.getStrValue(strTemp);
				%>
        <td style="font-size:10px">&nbsp;<%=strTemp%></td>
      </tr>
    </table></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="2">17 Registered Address</td>
		<td width="17%">17A Zip Code</td>
	</tr>
	<tr>
		<td width="2%">
		<img src="images/arrow.jpg" width="6" height="7" /></td>
		<td width="81%"><table width="98%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
        <%
				if(vEmployer != null && vEmployer.size() > 0)
					strTemp = (String)vEmployer.elementAt(2);
				else
					strTemp = "";
				strTemp = WI.getStrValue(strTemp);
				%>
        <td style="font-size:10px">&nbsp;<%=strTemp%></td>
      </tr>
    </table>
		</td>
		<td><table width="94%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
				<%
					if(vEmployer != null && vEmployer.size() > 0){
						strTemp = (String)vEmployer.elementAt(3);
					}else{
						strTemp = "";
					}
				%>
        <td align="center" style="font-size:12px"><%=strTemp%></td>
      </tr>
    </table></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(72);				
					//if(vEditInfo != null && vEditInfo.size() > 0)
					//	strTemp = (String)vEditInfo.elementAt(5);
					//strTemp = WI.fillTextValue("is_main_emp");
					strTemp = WI.getStrValue(strTemp);
					if(strTemp.equals("1")){
						strTemp = "<img src='images/x_status_box.jpg' width='15' height='15' />";
						strTemp2 = "<img src='images/status_box.jpg' width='15' height='15' />";
					}else{
						strTemp = "<img src='images/status_box.jpg' width='15' height='15' />";
						strTemp2 = "<img src='images/x_status_box.jpg' width='15' height='15' />";

					}
				%>
			 
        <td width="24%" height="18" align="right"><%=strTemp%></td>
        <td width="25%">Main Employer</td>
        <td width="6%" align="right"><%=strTemp2%></td>
        <td width="45%">Secondary Employer</td>
      </tr>
    </table></td>
  </tr>
<tr>
	<td>
	<b>Part III &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Employer Information (Previous)</b>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="25%">
		18 Taxpayer<br/>
		&nbsp;&nbsp;&nbsp;Identification No.		</td>
 		<td width="5%">&nbsp;
		<img src="images/arrow.jpg" width="6" height="7" /></td>
	  <td width="70%"><table width="70%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
        <%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(15);
				else
					strTemp = "";
				strTemp = WI.getStrValue(strTemp);
				%>
        <td style="font-size:12px">&nbsp;<%=strTemp%></td>
      </tr>
    </table></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="2">19 Employer's Name</td>
	</tr>
	<tr>
		<td width="2%">
		<img src="images/arrow.jpg" width="6" height="7" /></td>
	  <td width="98%"><table width="98%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
        <%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(16);
				else
					strTemp = "";
				strTemp = WI.getStrValue(strTemp);
				%>
        <td style="font-size:10px">&nbsp;<%=strTemp%></td>
      </tr>
    </table></td>
	</tr>
	</table>	</td>
  </tr>
<tr bgcolor="#999999">
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="2">20 Registered Address</td>
		<td width="17%">20A Zip Code</td>
	</tr>
	<tr>
		<td width="2%">
		<img src="images/arrow.jpg" width="6" height="7" /></td>
		<td width="81%"><table width="98%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
        <%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(17);
				else
					strTemp = "";
				strTemp = WI.getStrValue(strTemp);
				%>
        <td style="font-size:10px">&nbsp;<%=strTemp%></td>
      </tr>
    </table></td>
		<td><table width="94%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
      <tr>
        <%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(18);
					else
						strTemp = "";				
					strTemp = WI.getStrValue(strTemp);	
				%>
        <td align="center" style="font-size:12px"><%=strTemp%></td>
      </tr>
    </table></td>
	</tr>
	</table>	</td>
  </tr>
<tr>
	<td>
	<b>Part IV-A 				
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	Summary</b>	</td>
  </tr>
<tr bgcolor="#999999" valign="top">
	<td>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" cllspacing="0">
		<tr valign="top">
			<td width="3%">21</td>
			<td width="53%">Gross Compensation Income from<br/>
		  <font style="font-size:9px;">Present Employer (Item 41 plus Item 55)</font></td>
			<td width="6%">21</td>
			<td width="38%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(19);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="3%">22</td>
			<td width="53%"><font size="1"><b>Less: Total Non-Taxable</b><br/>
		  	Exempt (Item 41)</font></td>
			<td width="6%">22</td>
			<td width="38%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(20);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="3%">23</td>
			<td width="53%"><font size="1"><b>Taxable Compensation Income</b><br/>
		  	from Present Employer (Item 55)</font></td>
			<td width="6%">23</td>
			<td width="38%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(21);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="3%">24</td>
			<td width="53%"><font size="1"><b>Add: Taxable Compensation<br/>
		  	Income from Previous Exmployer</font></td>
			<td width="6%">24</td>
			<td width="38%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(22);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="3%">25</td>
			<td width="53%"><font size="1"><b>Gross Taxable<br/>
		  	Compensation Income</font></td>
			<td width="6%">25</td>
			<td width="38%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(23);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="3%">26</td>
			<td width="53%"><font size="1"><b>Less: Total Exemptions</b></font></td>
			<td width="6%">26</td>
 			<td width="38%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(24);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="3%">27</td>
			<td width="53%"><b>Less: Premium Paid on Health</b><br/>
		  	<font style="font-size:9px">and/or Hospital Insurance (if applicable)</font></td>
			<td width="6%">27</td>
			<td width="38%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(25);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="3%">28</td>
			<td width="53%"><font size="1"><b>Net Taxable</b><br/>
		  	Compensation Income</font></td>
			<td width="6%">28</td>
			<td width="38%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(26);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="3%">29</td>
			<td width="53%"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="53%"><font size="1"><b>Tax Due</b></font></td>
            </tr>
        </table></td>
			<td width="6%">29</td>
			<td width="38%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(27);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="3%">30</td>
			<td colspan="3"><font size="1">
			  <b>Amount of Taxes Withheld</b></font>			  </td>
		</tr>
		<tr valign="top">
			<td width="3%"></td>
			<td width="53%"><font size="1"><b>30A Present Employer</b></font></td>
			<td width="6%">30A</td>
			<td width="38%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(28);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr valign="top">
			<td width="3%"></td>
			<td width="53%"><font size="1"><b>30B Previous Employer</b></font></td>
			<td width="6%">30B</td>
			<td width="38%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(29);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>

		<tr valign="top">
			<td width="3%">31</td>
			<td width="53%"><font size="1"><b>Total Amount of Taxes Withheld<br/>
			As Adjusted</b></font></td>
			<td width="6%">31</td> 	
			<td width="38%"><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(30);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		</table>	</td>
</tr>
<tr>
	<td colspan="2" style="padding-left: 25px">
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We declare, under the penalties of perjury, that this certificate has been made in good faith, verified by us, and to the best of our knowledge and belief, is true and correct pursuant to the provisions of the National Internal Revenue Code, as amended, and the regulations issued under authority thereof.<br/>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr valign="top">
	<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(70);
	%>		
	<td width="56%" class="thinborderBOTTOM"><table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="14%" align="right">56</td>
      <td width="73%" align="center" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td width="13%">&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td align="center" nowrap>&nbsp;&nbsp;<font size="1">Present Employer/ Authorized Agent Signature Over Printed Name</font></td>
      <td>&nbsp;</td>
    </tr>
  </table></td>
	<td width="9%">Date Signed</td> 
	<td width="18%"><table width="75%" height="18" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr>
      <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(63);
						else
							strTemp = "";
						strTemp = WI.getStrValue(strTemp);
						strTemp = ConversionTable.replaceString(strTemp, "/", " / ");
					%>
      <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
    </tr>
  </table>
	  </td>
	<td width="17%"></td>
	</tr>
	<tr>
		<td colspan="4">CONFORME:</td>
	</tr>
	<tr valign="top">
	<td><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="11%" align="right"><b>57</b></td>
				<%
				if(vEmpInfo != null && vEmpInfo.size() > 0){
					strTemp = WI.formatName((String)vEmpInfo.elementAt(2), (String)vEmpInfo.elementAt(3), (String)vEmpInfo.elementAt(4), 7);
				}else{
					strTemp = "";
				}				
				%>
        <td width="56%" align="center" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp)%></td>
        <td width="33%">&nbsp;</td>
      </tr>
      <tr>
        <td height="16">CTC No.</td>
        <td align="center">&nbsp;Employee Signature Over Printed Name </td>
        <td>&nbsp;</td>
      </tr>
    </table>
	  </td>
	<td>Date Signed</td> 
	<td><table width="75%" height="18" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr>
      <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(64);
						else
							strTemp = "";
						strTemp = WI.getStrValue(strTemp);
						strTemp = ConversionTable.replaceString(strTemp, "/", " / ");
					%>
      <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
    </tr>
  </table>
	  </td>
	<td align="center" valign="bottom">Amount Paid </td>
	</tr>
	<tr valign="top">
	<%
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(59);
		}else{
			strTemp = WI.fillTextValue("emp_ctc_no");
		}
	%>
	<td> <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="15%">of Employee</td>
      <td width="27%"><table width="93%" height="18" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(59);
						else
							strTemp = "";
						strTemp = WI.getStrValue(strTemp);		
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
      <td width="21%">Place of Issue        </td>
      <td width="37%"><table width="93%" height="18" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(60);
						else
							strTemp = "";
						strTemp = WI.getStrValue(strTemp);
						strTemp = ConversionTable.replaceString(strTemp, "/", " / ");
					%>
          <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
        </tr>
      </table></td>
    </tr>
  </table></td>
	<td >Date of Issue</td>
	<%
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(61);
		}else{
			strTemp = WI.fillTextValue("ctc_issue_date");
		}
	%>	
	<td ><table width="75%" height="18" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr>
      <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(61);
						else
							strTemp = "";
						strTemp = WI.getStrValue(strTemp);
						strTemp = ConversionTable.replaceString(strTemp, "/", " / ");
					%>
      <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
    </tr>
  </table>
	  </td>
	<%
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(62);
		}else{
			strTemp = WI.fillTextValue("ctc_amt");
		}
	%>	
	<td align="center" ><table width="93%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr>
      <%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(62);
		
						strTemp = CommonUtil.formatFloat(strTemp, true);
						//strTemp = ConversionTable.replaceString(strTemp, ",", "");
						if(strTemp.equals("0.00"))
							strTemp = "";
					%>
      <td align="right" style="font-size:12px"><%=strTemp%>&nbsp;</td>
    </tr>
  </table></td>
	</tr>
	</table>	</td>
</tr>
<tr>
	<td colspan="2" align="center"><strong>To be accomplished under substituted filing</strong></td>
</tr>
<tr valign="top">
	<td>
	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I declare, under the penalties of perjury,  that the information herein stated are reported 
   under BIR Form No. 1604CF which has been filed with the Bureau of Internal Revenue.<br/><br/>
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
					
			<td align="center" class="thinborderBOTTOM"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="11%" align="right">58</td>
					<%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(71);
					%>						
          <td width="78%" align="center"><%=strTemp%></td>
          <td width="11%">&nbsp;</td>
        </tr>
      </table></td>
		</tr>
		<tr>
			<td align="center">Present Employer/ Authorized Agent Signature Over Printed Name</td>
		</tr>
		<tr>
			<td align="center">(Head of Accounting/Human Resource or Authorized Representative)</td>
		</tr>
	  </table>	</td>
	<td>
		&nbsp;&nbsp;&nbsp;I declare, under the penalties of perjury that i am qualified under substituted filing of Income Tax Returns(BIR Form No. 1700), since I received purely compensation income from only one employer in the Phils. for the calendar year; that taxes have been correctly withheld by my employer (tax due equals tax withheld);  that the  BIR Form No. 1604CF filed by  my  employer to the BIR shall constitute as my income tax return; and that BIR Form No. 2316 shall serve the same purpose as if BIR Form No. 1700 had been filed pursuant to the provisions of RR No. 3-2002, as amended.
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="25%" align="right">59</td>
				<%
				if(vEmpInfo != null && vEmpInfo.size() > 0){
					strTemp = WI.formatName((String)vEmpInfo.elementAt(2), (String)vEmpInfo.elementAt(3), (String)vEmpInfo.elementAt(4), 7);
				}else{
					strTemp = "";
				}				
				%>
		  <td width="50%" align="center" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp)%></td>
		  <td width="25%" align="center">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="3" align="center">Employee Signature Over Printed Name</td>
		</tr>
		</table>	</td>
</tr>
</table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
