<%@ page language="java" import="utility.*,java.util.Vector, payroll.PRPayslip" %>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payslip to use</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
function UpdateProp(strInfoIndex){
	document.form_.update_info.value ="1";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}
//called for add or edit.
function PageAction(strAction) {
	if(strAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}

function ReloadPage() {
	document.form_.submit();
}

function CancelRecord(){
	location = "./payslip_use.jsp?payslip_use="+document.form_.payslip_use.value;
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Configuration-Payslip to use","payslip_use.jsp");
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
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"payslip_use.jsp");
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

ReadPropertyFile rpf = new ReadPropertyFile();
Vector vRetResult  = new Vector();
//	String strPayslipUsed = null;	
	String strFieldType = null;
	boolean bolShowSignature = false;
	
if(WI.fillTextValue("update_info").compareTo("1") == 0){
	if (rpf.setSysProperty(dbOP, request,WI.fillTextValue("info_index")))
		strErrMsg = " Information updated successfully";
	else {
		strErrMsg = rpf.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = " Infomation not updated. Please refresh and try again";
	}
}

vRetResult = rpf.getAllSysProperty(dbOP);
int iIndex = -1;

%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="payslip_use.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: Payslip to use PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><span style="font-size:11px"><strong>&nbsp;Password to Access</strong></span></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><input type="password" name="access_pwd" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="24"></td>
    </tr>
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="23%">Grouping</td>
			<% 	
				strFieldType = WI.fillTextValue("payslip_use");
			%>
      <td width="73%"><font size="1">
        <select name="payslip_use" onChange="ReloadPage();">
          <option value="1">Payslip 1</option>
					<%if(strFieldType.equals("2")) {%>
          <option value="2" selected>Payslip 2</option>
          <%}else{%>
          <option value="2">Payslip 2</option>
          <%}%>
					<%if(strFieldType.equals("3")) {%>
          <option value="3" selected>Payslip 3</option>
          <%}else{%>
          <option value="3">Payslip 3</option>
          <%}%>					
        </select>
        <a href='javascript:UpdateProp("payslip_use")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Current Setting </td>
			<%
				if (vRetResult != null) 
					iIndex= vRetResult.indexOf("payslip_use");
			   else 
				 	iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
					 strTemp = (String)vRetResult.elementAt(iIndex+1);
					 vRetResult.removeElementAt(iIndex);
					 vRetResult.removeElementAt(iIndex);
				 }else 				 
				 	 strTemp = WI.fillTextValue("payslip_use");
			%>			
      <td>Payslip <%=strTemp%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Show  Signature Fields </td>
      <td><% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("PAYSLIP_SIGNATURES");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("PAYSLIP_SIGNATURES");
					bolShowSignature = strTemp.equals("1");
				%>
        <select name="PAYSLIP_SIGNATURES">
        <option value="0">No</option>
        <% if (strTemp.equals("1")){%>
        <option value="1" selected>Yes</option>
        <%}else{%>
        <option value="1">Yes</option>
        <%}%>
      </select>
      <font size="1"><a href='javascript:UpdateProp("PAYSLIP_SIGNATURES")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr color="#0000FF" size="1"></td>
    </tr>
	</table>
	<%if(strFieldType.equals("1")){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="18" colspan="4">Cut off :&nbsp;(Cut - off)</td>
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="4">Name :
        (Employee name)</td>	
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="4">Department :&nbsp;(Department)</td>
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="2" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td colspan="2" class="thinborderTOPBOTTOM" height="18"><strong>SALARY/COMPENSATION</strong></td>
          </tr>
          <tr> 
            <td width="68%" class="thinborderNONE" height="18">&nbsp;Basic salary</td>
            <td width="32%" align="right" class="thinborderNONE">#</td>
          </tr>
          <tr> 
            <td class="thinborderNONE" height="18">&nbsp;Transportation Allowance</td>
            <td align="right" class="thinborderNONE">#</td>
          </tr>
          
          <tr> 
            <td class="thinborderNONE" height="18">&nbsp;Additional Payment Amount</td>
            <td align="right" class="thinborderNONE">#</td>
          </tr>
					
          <tr> 
            <td class="thinborderNONE" height="18">&nbsp;Part time/ Extra Salary</td>
            <td align="right" class="thinborderNONE">#</td>
          </tr>
          <tr> 
            <td class="thinborderNONE" height="18">&nbsp;Night Differential</td>
            <td align="right" class="thinborderNONE">#</td>
          </tr>
          <tr> 
            <td class="thinborderNONE" height="18">&nbsp;Overtime Amount</td>
            <td align="right" class="thinborderNONE">#</td>
          </tr>
          <tr> 
            <td class="thinborderNONE" height="18">&nbsp;Tardiness &amp; absences</td>
            <td align="right" class="thinborderNONE">#</td>
          </tr>
        </table></td>
      <td colspan="2" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td colspan="3" class="thinborderTOPBOTTOM" height="18"><strong>DEDUCTIONS</strong></td>
          </tr>
          <tr> 
            <td colspan="2" class="thinborderNONE" height="18">&nbsp;W/Holding 
              Tax</td>
            <td width="38%" align="right" class="thinborderNONE">#</td>
          </tr>
          <tr> 
            <td colspan="2" class="thinborderNONE" height="18">&nbsp;SSS</td>
            <td align="right" class="thinborderNONE">#</td>
          </tr>
          <tr> 
            <td colspan="2" class="thinborderNONE" height="18">&nbsp;PhilHealth</td>
            <td align="right" class="thinborderNONE">#</td>
          </tr>
          <tr> 
            <td colspan="2" class="thinborderNONE" height="18">&nbsp;PAG-IBIG</td>
            <td align="right" class="thinborderNONE">#</td>
          </tr>
          <tr> 
            <td height="18" colspan="2" class="thinborderNONE">&nbsp;<font color="#0000FF">Grouped Deductions</font></td>
            <td align="right" class="thinborderNONE">#</td>
          </tr>
          <tr> 
            <td colspan="2" class="thinborderNONE" height="18">&nbsp;Advances &amp; Other Ded</td>            
            <td align="right" class="thinborderNONE">#</td>
          </tr>
        </table></td>
      <td colspan="2" valign="top" class="thinborderBOTTOMLEFTRIGHT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="73%" height="18" class="thinborderTOP">&nbsp;</td>
            <td width="27%" class="thinborderTOP">&nbsp;</td>
          </tr>
          <tr> 
            <td><font color="#0000FF">&nbsp;Grouped earnings</font></td>
            <td align="right" class="thinborderNONE">#</td>
          </tr>
          <tr>
            <td height="18" class="thinborderNONE">&nbsp;OTHER EARNINGS </td>
            <td align="right" class="thinborderNONE">#</td>
          </tr>
          <tr> 
            <td height="18" class="thinborderNONE"><strong>&nbsp;GROSS SALARY</strong></td>
            <td align="right" class="thinborderNONE">#</td>
          </tr>
          <tr> 
            <td height="10"></td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td height="18" class="thinborderTOP"><strong>&nbsp;TOTAL 
              DEDUCTIONS</strong></td>
            <td align="right" class="thinborderTOP">#</td>
          </tr>
          <tr> 
            <td height="18" class="thinborderNONE"><strong>&nbsp;ADJUSTMENT AMOUNT</strong></td>
            <td align="right">#</td>
          </tr>
          <tr> 
            <td height="18">&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          
        </table></td>
    </tr>
    <tr> 
      <td width="20%" height="21" class="thinborderBOTTOMLEFT"><font size="1"><strong>&nbsp;&nbsp;GROSS 
        SALARY</strong></font></td>
      <td width="17%" height="21" align="right" class="thinborderBOTTOMLEFT">#</td>
      <td width="20%" class="thinborderBOTTOMLEFT"><font size="1"><strong>&nbsp;&nbsp;TOTAL 
        DEDUCTIONS</strong></font></td>
      <td width="13%" align="right" class="thinborderBOTTOMLEFT">#</td>
      <td width="17%" class="thinborderBOTTOMLEFT"><strong>&nbsp;&nbsp;NET 
      SALARY :</strong></td>
      <td width="13%" align="right" class="thinborderBOTTOMLEFTRIGHT">#</td>
    </tr>
  </table>		
	<%if(bolShowSignature){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="40%" height="30">&nbsp;</td>
    <td width="28%" align="center" class="thinborderBOTTOM">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="30%" align="center" valign="bottom" class="thinborderBOTTOM">(Employee name)</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td align="center">Manager Signature </td>
    <td align="center">&nbsp;</td>
    <td align="center">Employee Signature </td>
  </tr>
</table>
	<%}%>
	 <%}else if(strFieldType.equals("2")){%>
	 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
     <tr>
       <td width="10%"><font size="1"><span class="thinborderNONE">DEPARTMENT </span></font></td>
       <td colspan="2"><font size="1">(Department)<font size="1">&nbsp;</font></font></td>
       <td width="29%" align="right" class="thinborderNONE">Payslip : (pay period) </td>
       <td colspan="2">&nbsp;</td>
     </tr>
     <tr>
       <td height="17" class="thinborderBOTTOM"><font size="1">NAME</font></td>
       <td width="21%" class="thinborderBOTTOM">(Name of employee)</td>
       <td width="11%" class="thinborderBOTTOM">(emp id)</td>
       <td class="thinborderBOTTOM">&nbsp;</td>
       <td width="16%" class="thinborderBOTTOM">RATE : (hourly rate) </td>
       <td width="13%" colspan="2" class="thinborderBOTTOM">&nbsp;</td>
     </tr>
     <tr>
       <td height="18" colspan="3" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
           <tr>
             <td width="26%" valign="bottom" class="thinborderNONE" height="18">Earnings</td>
             <td width="38%" valign="bottom" class="thinborderNONE">Basic Pay </td>
             <td width="36%" height="10" align="right" valign="bottom" class="thinborderNONE">#</td>
           </tr>
           <tr>
             <td height="18" valign="bottom">&nbsp;</td>
             <td  valign="bottom"><font size="1">Overtime</font></td>
             <td align="right" valign="bottom">#</td>
           </tr>
           <tr>
             <td height="18" valign="bottom">&nbsp;</td>
             <td valign="bottom"><font size="1">Night Differential </font></td>
             <td align="right" valign="bottom">#</td>
           </tr>
           <tr>
             <td height="18" valign="bottom" class="thinborderNONE">&nbsp;</td>
             <td valign="bottom" class="thinborderNONE">Holiday pay </td>
             <td align="right" valign="bottom">#</td>
           </tr>
       </table></td>
       <td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
           <%if(bolIsSchool){%>
					 <tr>
             <td height="18" valign="bottom" class="thinborderNONE">Overload / Faculty pay</td>
             <td align="right" valign="bottom" class="thinborderNONE">#</td>
           </tr>
					 <%}%>
           <tr>
             <td height="18" class="thinborderNONE">Other Income </td>
             <td align="right" class="thinborderNONE">#</td>
           </tr>
           <tr>
             <td height="18" width="70%" class="thinborderNONE">Abs/UT/Late</td>
             <td width="30%" align="right" class="thinborderNONE">#</td>
           </tr>
       </table></td>
       <td align="right" valign="bottom" class="thinborderBOTTOMonly"><font size="2">Gross Salary </font></td>
       <td align="right" valign="bottom" class="thinborderBOTTOMonly">Adjustment</td>
     </tr>
     <tr>
       <td height="10" colspan="7" valign="top"></td>
     </tr>
     <tr>
       <td height="18" colspan="3" valign="top" class="thinborderBOTTOM"><table width="100%" border="0" cellspacing="0" cellpadding="0">
           <tr>
             <td height="18" width="26%" valign="bottom" class="thinborderNONE">Deductions</td>
             <td width="38%" valign="bottom" class="thinborderNONE" ><font color="#000000" size="1">W/Tax</font></td>
             <td width="36%" align="right" valign="bottom">#</td>
           </tr>
           <tr>
             <td height="18" valign="bottom">&nbsp;</td>
             <td valign="bottom"><font color="#000000" size="1">SSS Premium</font></td>
             <td align="right" valign="bottom">#</td>
           </tr>
           <tr>
             <td height="18" valign="bottom">&nbsp;</td>
             <td valign="bottom"><font color="#000000" size="1">Philhealth</font></td>
             <td align="right" valign="bottom">#</td>
           </tr>
           <tr>
             <td height="18" valign="bottom">&nbsp;</td>
             <td valign="bottom"><font size="1">Pag-ibig Premium </font></td>
             <td align="right" valign="bottom">#</td>
           </tr>
           <%if(bolIsSchool){%>
					 <tr>
             <td height="18" valign="bottom">&nbsp;</td>
             <td valign="bottom"><font size="1">PERAA Premium </font></td>
             <td align="right" valign="bottom">#</td>
           </tr>
					 <%}%>
           <tr>
             <td height="18" valign="bottom">&nbsp;</td>
             <td valign="bottom"><font size="1">GSIS Premium </font></td>
             <td align="right" valign="bottom">#</td>
           </tr>
       </table></td>
       <td valign="top" class="thinborderBOTTOM"><table width="100%" border="0" cellspacing="0" cellpadding="0">
           <tr>
             <td width="69%" class="thinborderNONE" height="18">&nbsp;<font color="#0000FF">Grouped Deductions</font></td>
             <td width="31%" align="right" class="thinborderNONE">#</td>
           </tr>
           <tr>
             <td class="thinborderNONE" height="18">&nbsp;OTHERS</td>
             <td align="right" class="thinborderNONE">#</td>
           </tr>
       </table></td>
       <td align="right" valign="bottom" class="thinborderBOTTOM"><font size="2">Total Ded </font></td>
       <td align="right" valign="bottom" class="thinborderBOTTOM"><strong><font size="2">Net Salary </font>&nbsp;</strong></td>
     </tr>
     <tr>
       <td height="18" valign="top" class="thinborderNONE">Other Inc. </td>
       <td height="18" colspan="2" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
           <tr>
             <td width="52%"  height="16" class="thinborderNONE"><font color="#0000FF">Grouped earnings</font></td>
             <td width="48%" align="right" class="thinborderNONE">&nbsp;</td>
           </tr>
           <tr>
             <td class="thinborderNONE">OTHERS</td>
             <td align="right" class="thinborderNONE">&nbsp;</td>
           </tr>
       </table></td>
       <td align="right" valign="bottom">&nbsp;</td>
			 <td align="right" valign="bottom"></td>
			 <td align="right" valign="bottom"></td>
     </tr>
     <tr>
       <td height="18" colspan="3" valign="top" class="thinborderNONE">Cut - off Date : </td>
       <td colspan="3" align="right" valign="bottom">
			 <%if(bolShowSignature){%>
			 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td width="28%" height="30">&nbsp;</td>
					<td width="2%" align="center">&nbsp;</td>
					<td width="30%" align="center" valign="bottom" class="thinborderBOTTOM">(Employee name)</td>
				</tr>
				<tr>
					<td align="center" class="thinborderNONE">&nbsp;</td>
					<td align="center">&nbsp;</td>
					<td align="center" class="thinborderNONE">Employee Signature </td>
				</tr>
			</table>
			<%}%>
			</td>
		 </tr>
   </table>
	 <%}else{%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td width="17%" class="thinborderNONEcl">&nbsp;PAYROLL PERIOD</td>
			<td width="32%" class="thinborderNONEcl">&nbsp;</td>
			<td width="28%">&nbsp;</td>
			<td width="23%">&nbsp;</td>
		</tr>
		<tr> 
			<td height="17" class="thinborderNONEcl">&nbsp;NAME</td>
			<td class="thinborderNONEcl">&nbsp;</td>
		  <td colspan="2" class="thinborderNONEcl">&nbsp;DEPARTMENT : </td>
		</tr>
		
		<tr> 
			<td height="18" colspan="2" valign="top" class="thinborderTOP"><table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr valign="bottom"> 
						<td height="25" colspan="3"><div align="center"><strong>EARNINGS</strong></div></td>
					</tr>
					<tr>
						<td height="10" valign="bottom"><font size="1">RATE / DAY</font></td>
						<td align="right" valign="bottom">#</td>
						<td>&nbsp;</td> 
					</tr>
					
					<tr>
						<td height="10" valign="bottom"><font size="1">NIGHT DIFFERENTIAL</font></td>
						<td align="right" valign="bottom">#</td>
						<td>&nbsp;</td> 
					</tr>
					<tr>
						<td height="10" valign="bottom"><font size="1">ADJUSTMENT</font></td>
						<td align="right" valign="bottom">#</td>
						<td>&nbsp;</td> 
					</tr>
					<%if(bolIsSchool){%>
					<tr>
						<td height="10" valign="bottom"><font size="1">OVERLOAD</font></td>
						<td align="right" valign="bottom">#</td>
						<td>&nbsp;</td> 
					</tr>		
					<%}%>
					<tr>
						<td height="10" valign="bottom"><font size="1">OVERTIME&nbsp;</font></td>
						<td align="right" valign="bottom">#</td>
						<td>&nbsp;</td> 
					</tr>				
					<tr>
						<td height="10" valign="bottom"><font color="#0000FF" size="1">GROUPED EARNINGS</font></td>
						<td align="right" valign="bottom">#</td>
							<td>&nbsp;</td> 
					</tr>				
					<tr>
						<td valign="bottom"><font size="1"> INCENTIVE</font></td>
						<td align="right" valign="bottom">#</td>
						<td>&nbsp;</td> 
					</tr>
					<tr>
						<td width="47%"><font size="1">OTHERS</font></td>			
						<td width="47%" align="right">#</td>
						<td width="6%">&nbsp;</td>
					</tr>
					<tr>
					  <td class="thinborderNONE">TARDINESS &amp; ABSENCES </td>
					  <td align="right">#</td>
					  <td>&nbsp;</td>
				  </tr>
					<tr>
					  <td><font size="1"></font></td>
					  <td align="right">&nbsp;</td>
					  <td>&nbsp;</td>
				  </tr>
					<tr>
					  <td><font size="1">OTHERS</font></td>
					  <td align="right">#</td>
					  <td>&nbsp;</td>
				  </tr>     
				</table></td>
			<td colspan="2" valign="top" class="thinborderTOPLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr valign="bottom"> 
						<td height="25" colspan="3"><div align="center"><strong>DEDUCTIONS</strong></div></td>
					</tr>
					<tr> 
						<td valign="bottom"><font size="1">&nbsp;&nbsp; W/HOLDING 
						TAX </font></td>
						<td align="right" valign="bottom">#</td>
						<td align="right">&nbsp;</td>
					</tr>
					<tr>
						<td valign="bottom"><font size="1">&nbsp;&nbsp; SSS 
						PREM.</font></td>
						<td align="right" valign="bottom">#</td>
						<td align="right">&nbsp;</td>
					</tr>
					<tr>
						<td valign="bottom"><font size="1"> &nbsp;&nbsp;PHILHEALTH 
						PREM.</font></td>
						<td align="right" valign="bottom">#</td>
						<td align="right">&nbsp;</td>
					</tr>
					<tr>
						<td valign="bottom"><font size="1">&nbsp;&nbsp;PAG-IBIG PREM. </font></td>
						<td align="right" valign="bottom">#</td>
						<td align="right">&nbsp;</td>
					</tr>
					<%if(bolIsSchool){%>
					<tr>
						<td valign="bottom"><font size="1">&nbsp;&nbsp;PERAA PREM.</font></td>
						<td align="right" valign="bottom">#</td>
						<td align="right">&nbsp;</td>
					</tr>				
					<%}%>
					<tr>
						<td valign="bottom">&nbsp;<font color="#0000FF" size="1">GROUPED DEDUCTIONS</font></td>
						<td align="right" valign="bottom">#</td>
						<td align="right">&nbsp;</td>
					</tr>
  
					<tr> 
						<td valign="bottom"><font size="1">&nbsp;&nbsp;OTHERS</font></td>
 
						<td align="right" valign="bottom">#</td>
						<td align="right">&nbsp;</td>
					</tr>
					<tr>
						<td width="44%">&nbsp;</td>
						<td width="51%">&nbsp;</td>
						<td width="5%">&nbsp;</td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td height="19" colspan="2" valign="top" class="thinborderBOTTOM"><table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width="72%" height="18" align="right"><font size="1">TOTAL 
						EARNINGS&nbsp;</font></td>
					<td width="22%" align="right">#</td>
					<td width="6%">&nbsp;</td>
				</tr>
				
			</table></td>
			<td colspan="2" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
				
				<tr>
					<td height="18" width="55%"><font size="1">&nbsp;&nbsp;TOTAL DEDUCTIONS</font></td>
					<td width="45%" align="right">#</td>
				</tr>
				<tr>
					<td height="19" valign="bottom"><strong>&nbsp;&nbsp;NET SALARY :</strong></td>
					<td align="right" valign="bottom">#</td>
				</tr>
			</table></td>
		</tr>
	</table>	
	<%if(bolShowSignature){%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr>
				<td width="19%" height="30"><span class="thinborderNONE">Employee Signature </span></td>
				<td width="28%" align="center" valign="bottom" class="thinborderBOTTOM">(Employee name)</td>
				<td width="53%" align="center" valign="bottom">&nbsp;</td>
			</tr>
		</table>	
		<%}%>		 
	 <%}%>
	 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">Note : Items in blue are variable. Depending on the group names created in the payslip setting page. </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
     </tr>
    <tr> 
      <td width="77%" height="25" align="center"><font size="1">
        <input type="button" name="cancel" value=" Reload " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
      Click to reload </font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
      <td height="25">&nbsp;</td>
    </tr>
   <tr>
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="info_index">
<input type="hidden" name="update_info" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
