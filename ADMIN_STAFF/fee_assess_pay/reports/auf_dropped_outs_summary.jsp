<%@ page language="java" import="utility.*, EnrlReport.*, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
	TABLE.jumboborder {
    border-top: solid 2px #000000;
    border-bottom: solid 2px #000000;
    border-left: solid 2px #000000;
    border-right: solid 2px #000000;
    }
    
	TD.jumboBOTTOM {
    border-right: solid 1px #D7D7D7;
	border-bottom: solid 2px #000000;
    }

   
    TD.miniTOP {
    border-right: solid 1px #D7D7D7;
    }
    
    TD.medTOP {
    border-top: solid 1px #000000;
    border-right: solid 1px #D7D7D7;
    border-bottom: solid 1px #D7D7D7;
    }

    TD.miniTOPRIGHT {
    border-top: solid 1px #D7D7D7;
    border-right: solid 1px #D7D7D7;
    }
    
    TD.miniTOPRIGHTBOTTOM {
    border-top: solid 1px #D7D7D7;
    border-right: solid 1px #D7D7D7;
    border-bottom: solid 1px #000000;
    }
    
-->
</style>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language = "javascript">
function PrintPg(){

	document.bgColor = "#FFFFFF";
	document.getElementById('tHeader').deleteRow(0);
	document.getElementById('tHeader').deleteRow(0);
	window.print();
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function JumpReportType() {
	location = "./auf_dropped_outs_details.jsp?sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+"&semester="+
	document.form_.semester[document.form_.semester.selectedIndex].value;
}
</script>
</head>
<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT","auf_dropped_outs_summary.jsp");
	
	Vector vRetResult = null; //the big vector
	Vector vStudents = null; //students. 'nuff said
	Vector vFeeInfo = null; //fee list
	Vector vTemp1 = null; //use this to get the vector in the vFeeInfo
	Vector vFeeNames = null; //fee names
	Vector vEternalSum = new Vector();// 'nuff said
	String[] astrConvertToSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

	/**counters galore!****/
	int iCtr1 = 0;
	int iCtr2 = 0;
	int iCtr3 = 0; //student counter (reset when course is new)
	int iCtr4 = 0; 
	int iEternalStudent = 0; //eternal student counter

	String strErrMsg = null;

	/**keep the current course here**/
	String strTemp = null;
	/****other temporary stuff******/
	String strTemp2 = null;
	
	
	/*****since it's too bothersome to format it while printing get it once and keep**/
	double dTuition = 0d;
	double dService = 0d;
	double dPayment = 0d;
	double dRefund = 0d;
	double dLoss = 0d;
	
	Vector vSums = new Vector(); //keep the totals in this vector
	
	/*****used for  adding values****/
	double dTemp1 = 0d;
	double dTemp2 = 0d;

	boolean bolNew = true;
	//System.out.println(WI.fillTextValue("semester"));
	DailyCashCollection dCashCol = new DailyCashCollection();

	if (WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("sy_to").length()>0 
	&& WI.fillTextValue("semester").length()>0){
	vRetResult = dCashCol.dropoutList(dbOP, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
	if (vRetResult != null)
	{
		vFeeNames = (Vector)vRetResult.elementAt(0);
		vStudents = (Vector)vRetResult.elementAt(1);
		vFeeInfo = (Vector)vRetResult.elementAt(2);
	}
	else
		strErrMsg = dCashCol.getErrMsg();
	}
	dbOP.forceAutoCommitToTrue();
    dbOP.executeUpdateWithTrans("update enrl_final_cur_list set is_valid = 0,new_added_dropped = 2 where enroll_index in "+
		"(select enroll_index from ENRL_ADD_DROP_HIST where is_del = 0 and add_drop_status = 1) and is_valid = 1 ", null, null, false);

//System.out.println(WI.fillTextValue("sy_from"));
%>
<form actiont="./auf_dropped_outs_summary.jsp" name="form_" method="post">
<body bgcolor="#FFFFFF">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="tHeader">
	<tr>
		<td height="30">&nbsp;
		 <%strTemp = WI.fillTextValue("sy_from");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");%> 
			<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%strTemp = WI.fillTextValue("sy_to");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");%> 
			<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="0">Summer</option>
          <%strTemp = WI.fillTextValue("semester");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>
      &nbsp;&nbsp;&nbsp;&nbsp; <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a> 
      &nbsp;&nbsp;&nbsp;&nbsp; Report Type : 
      <input type="radio" value="0" name="rep_type" onClick="JumpReportType();"> Detailed &nbsp; 
      <input type="radio" value="1" name="rep_type" checked> Summary </td>
	</tr>
	<%if (vRetResult!= null && vRetResult.size()>0){%>
	<tr>
		<td height="30">&nbsp;<a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a><font style="font-size:11px;">Click to print</font></a></td>
	</tr>
	<%}%>
  </table>
<%if (vRetResult != null && vRetResult.size()>0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
	<tr>
		<td height="30" align="center"><font style="font-size:11px;">Angeles University Foundation<br>
		Angeles City</font><br><br><font size="2"><strong>DROPPED OUTS SUMMARY</strong></font></td>
	</tr>
	<tr>
		<td height="10">&nbsp;</td>
	</tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="jumboborder">
    <tr>
    	<td colspan="3"><font style="font-size:11px;">DROPPED OFFICIALLY</font></td>
    	<%for (iCtr1 = 0; iCtr1 < vFeeNames.size()+4; ++iCtr1){%>
			<td width="150" align="center" class="miniTOP">&nbsp;</font></td>
		<%}%>
    </tr>
    <tr>
    	<td colspan="4" class="miniTOPRIGHT"><font style="font-size:11px;">
    	<%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("semester"))]%> AY <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%>
    	</font></td>
    	<%for (iCtr1 = 0; iCtr1 < vFeeNames.size()+3; ++iCtr1){%>
			<td width="150" align="center" class="miniTOPRIGHT">&nbsp;</font></td>
		<%}%>
    </tr>
    <tr>
    	<td class="miniTOPRIGHT" width="150">&nbsp;</td>
    	<td class="miniTOPRIGHT" width="85">&nbsp;</td>
    	<%for (iCtr1 = 0; iCtr1 < vFeeNames.size()+5; ++iCtr1){%>
			<td width="150" align="center" class="miniTOPRIGHT">&nbsp;</td>
		<%}%>
    </tr>
    <tr> 
	
		<td align="center" class="miniTOPRIGHTBOTTOM"><font style="font-size:11px;">COURSE</font></td>
		<td align="left" class="miniTOPRIGHTBOTTOM"><font style="font-size:11px;">NOS</font></td>
		
    <td align="center" class="miniTOPRIGHTBOTTOM"><font style="font-size:11px;">TOT. ASSESSMENT</font></td>
		<td align="right" class="miniTOPRIGHTBOTTOM"><font style="font-size:11px;">PAYMENT</font></td>
		<td align="right" class="miniTOPRIGHTBOTTOM"><font style="font-size:11px;">SER FEE</font></td>
		<td align="right" class="miniTOPRIGHTBOTTOM"><font style="font-size:11px;">REFUND</font></td>
		<td align="right" class="miniTOPRIGHTBOTTOM"><font style="font-size:11px;">LOSS</font></td>
		<%for (iCtr1 = 0; iCtr1 < vFeeNames.size(); ++iCtr1){%>
			<td align="right" class="miniTOPRIGHTBOTTOM"><font style="font-size:11px;"><%=(String)vFeeNames.elementAt(iCtr1)%></font></td>
		<%}%>
	</tr>
	  <tr> 
		<td align="center" class="miniTOP">&nbsp;</td>
		<td align="center" class="miniTOP">&nbsp;</td>
		<td align="center" class="miniTOP">&nbsp;</td>
		<td align="center" class="miniTOP">&nbsp;</td>
		<td align="center" class="miniTOP">&nbsp;</td>
		<td align="center" class="miniTOP">&nbsp;</td>
		<td align="center" class="miniTOP">&nbsp;</td>
		<%for (iCtr1 = 0; iCtr1 < vFeeNames.size(); ++iCtr1){%>
			<td align="center" class="miniTOP">&nbsp;</td>
		<%}%>
	</tr>
		<%
//		System.out.println("Students: "+vStudents);
//		System.out.println("Fee Names: "+vFeeNames);
//		System.out.println("Fee Info: "+vFeeInfo);

		for (iCtr4 = 0; iCtr4 < vFeeNames.size()+5; ++iCtr4)
				vEternalSum.addElement(Double.valueOf("0"));

		for (iCtr2 = 0, iCtr3 =0; iCtr2 < vStudents.size(); iCtr2+=9) {

		

		dTuition = Double.parseDouble(((Double)vStudents.elementAt(iCtr2+5)).toString());
		dService = Double.parseDouble(((Double)vStudents.elementAt(iCtr2+7)).toString());	
		dPayment = Double.parseDouble(((Double)vStudents.elementAt(iCtr2+6)).toString());
		dRefund = Double.parseDouble(((Double)vStudents.elementAt(iCtr2+8)).toString());	
		dLoss = dTuition - dService;


		if (bolNew)
		{
			vSums.addElement(Double.valueOf(Double.toString(dTuition)));
			vSums.addElement(Double.valueOf(Double.toString(dPayment)));
			vSums.addElement(Double.valueOf(Double.toString(dService)));
			vSums.addElement(Double.valueOf(Double.toString(dRefund)));
			vSums.addElement(Double.valueOf(Double.toString(dLoss)));
			for (iCtr4 = 0; iCtr4 < vFeeNames.size(); ++iCtr4)
				vSums.addElement(Double.valueOf("0"));
		}
		else
		{
			dTemp1 = Double.parseDouble(((Double)vSums.elementAt(0)).toString());
			dTemp2 = Double.parseDouble(Double.toString(dTuition));
			dTemp1 += dTemp2;
			vSums.setElementAt(Double.valueOf(Double.toString(dTemp1)),0);
			
			dTemp1 = Double.parseDouble(((Double)vSums.elementAt(1)).toString());
			dTemp2 = Double.parseDouble(Double.toString(dPayment));
			dTemp1 += dTemp2;
			vSums.setElementAt(Double.valueOf(Double.toString(dTemp1)),1);
			
			dTemp1 = Double.parseDouble(((Double)vSums.elementAt(2)).toString());
			dTemp2 = Double.parseDouble(Double.toString(dService));
			dTemp1 += dTemp2;
			vSums.setElementAt(Double.valueOf(Double.toString(dTemp1)),2);
			
			dTemp1 = Double.parseDouble(((Double)vSums.elementAt(3)).toString());
			dTemp2 = Double.parseDouble(Double.toString(dRefund));
			dTemp1 += dTemp2;
			vSums.setElementAt(Double.valueOf(Double.toString(dTemp1)),3);
			
			dTemp1 = Double.parseDouble(((Double)vSums.elementAt(4)).toString());
			dTemp2 = Double.parseDouble(Double.toString(dLoss));
			dTemp1 += dTemp2;
			vSums.setElementAt(Double.valueOf(Double.toString(dTemp1)),4);
		}

		if(vFeeInfo.elementAt(vFeeInfo.indexOf((String)vStudents.elementAt(iCtr2))+1)!=null)
			vTemp1 = (Vector)vFeeInfo.elementAt(vFeeInfo.indexOf((String)vStudents.elementAt(iCtr2))+1);
		else
			vTemp1 = null;
		if (vTemp1!=null){			
		for (iCtr4 = 0; iCtr4 < vFeeNames.size(); ++iCtr4) {
				if (vTemp1.indexOf((String)vFeeNames.elementAt(iCtr4))!= -1){
				dTemp1 = Double.parseDouble(((Double)vSums.elementAt(iCtr4+5)).toString());
				dTemp2 = Double.parseDouble((String)vTemp1.elementAt((vTemp1.indexOf((String)vFeeNames.elementAt(iCtr4)))+1));
				dTemp1 += dTemp2;
				vSums.setElementAt(Double.valueOf(Double.toString(dTemp1)),iCtr4+5);
				}//if found
			}//for loop
		} //if there is a list of scores
		
		if ((iCtr2+12) < vStudents.size()){
		strTemp = (String)vStudents.elementAt(iCtr2+3);
		if (strTemp.equals((String)vStudents.elementAt(iCtr2+12)))
		{
			bolNew = false;
			++iCtr3;
		}
		else
		{
			bolNew = true;
			
			}
		}
	if (bolNew || (iCtr2+12) >= vStudents.size()) {%>
		<tr>
			<td class="miniTOPRIGHT"><font style="font-size:11px;"><strong>&nbsp;<%=(String)vStudents.elementAt(iCtr2+3)%></strong></font></td>
			<td class="miniTOPRIGHT"><font style="font-size:11px;"><%=iCtr3+1%></font></td>
			<%for (iCtr4 = 0; iCtr4 < vSums.size(); ++iCtr4){%>
			<td class="miniTOPRIGHT" align="right"><font style="font-size:11px;"><%=CommonUtil.formatFloat(Double.parseDouble(((Double)vSums.elementAt(iCtr4)).toString()),true)%></font></td>
			<%
			dTemp1 = Double.parseDouble(((Double)vSums.elementAt(iCtr4)).toString());
			dTemp2 = Double.parseDouble(((Double)vEternalSum.elementAt(iCtr4)).toString());
			dTemp2 += dTemp1;
			vEternalSum.setElementAt(Double.valueOf(Double.toString(dTemp2)),iCtr4);
			}%>
		</tr>
		<%if (!((iCtr2+12) >= vStudents.size())){%>
		<tr>
    	<td class="miniTOPRIGHT">&nbsp;</td>
    	<td class="miniTOPRIGHT">&nbsp;</td>
    	<%for (iCtr1 = 0; iCtr1 < vSums.size(); ++iCtr1){%>
			<td width="150" align="center" class="miniTOPRIGHT">&nbsp;</td>
		<%}%>
	    </tr>
	    <%}%>
	<%
	iEternalStudent += (iCtr3+1);
	iCtr3 = 0;
	vSums = new Vector();
	}}%>
	<tr>
		<td class="miniTOPRIGHT"><font style="font-size:11px;">TOTAL</font></td>
		<td class="medTOP"><font style="font-size:11px;"><%=iEternalStudent%></font></td>
		<%for (iCtr4 = 0; iCtr4 < vEternalSum.size(); ++iCtr4){%>
			<td class="medTOP" align="right"><font style="font-size:11px;">
			<%=CommonUtil.formatFloat(Double.parseDouble(((Double)vEternalSum.elementAt(iCtr4)).toString()),true)%>
			</font></td>
		<%}%>
	</tr>
   </table>
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>