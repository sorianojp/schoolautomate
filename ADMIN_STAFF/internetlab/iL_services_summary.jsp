<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>

<script language="JavaScript">
<!--
	function viewList(){
		var loadPg = "./cafe_updateOR.jsp";
		var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}

	function ViewRecords(){
		document.dtr_op.iAction.value = 4;
		document.dtr_op.prepareToEdit.value = 0;
	}
	function PrepareToEdit(index,bTimeInTimeOut){
 		document.dtr_op.prepareToEdit.value = 1;
		document.dtr_op.bTimeIn.value= bTimeInTimeOut;
		document.dtr_op.info_index.value = index;
	}
	function AddRecord(){
		document.dtr_op.iAction.value = 1;
	}
	function EditRecord(){
		document.dtr_op.iAction.value = 2;
		document.dtr_op.bTimeIn.value = document.dtr_op.strStatus1.value;
	}
	function CancelEdit(){
		location = "./edit_dtr.jsp?emp_id="+document.dtr_op.emp_id.value+"&requested_date="+document.dtr_op.requested_date.value;
	}

	function DeleteRecord(index){
		document.dtr_op.iAction.value = "0";
		document.dtr_op.info_index.value = index;
	}
	function ClearDate(){
	 document.dtr_op.requested_date.value = "";
	 //document.dtr_op.submit();
	}

	function updateWH(strIndex){
	var loadPg = "./wh_update.jsp?emp_id=" + strIndex;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=no,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	}
-->
</script>
<body bgcolor="#D2AE72">
<form action="../e_dtr/dtr_operations/./add_dtr.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INTERNET OTHER SERVICES - SUMMARY OF OTHER CHARGES PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25"><div align="right"><font size="1"><strong>Date / Time :</strong> 
          $date_now / $time_now</font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="9%" height="25">&nbsp;</td>
      <td width="12%">School Year </td>
      <td width="24%"><input name="textfield3" type="text" size="4">
        to 
        <input name="textfield32" type="text" size="4"></td>
      <td width="6%">Term </td>
      <td width="49%"><select name="select3">
        </select></td>
    </tr>
    <tr> 
      <td height="29">&nbsp; </td>
      <td height="29">Date Range </td>
      <td height="29" colspan="3">From 
        <input name="textfield2" type="text" size="10"> <img src="../../images/calendar_new.gif"> 
        &nbsp;&nbsp;&nbsp;&nbsp;to&nbsp;&nbsp; <input name="textfield22" type="text" size="10"> 
        <img src="../../images/calendar_new.gif"> </td>
    </tr>
    <tr> 
      <td height="29" colspan="5"><hr size="1" noshade></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
      <td height="25">Service Type Code</td>
      <td width="60%" height="25"> <select name="select4">
        </select></td>
    </tr>
    <tr> 
      <td width="8%" height="15">&nbsp;</td>
      <td width="13%" height="15">&nbsp;</td>
      <td height="15">Service Type Name</td>
      <td height="15"><strong>$service_name</strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
      <td width="19%" height="25">Service Sub-Type Name</td>
      <td height="25"><select name="select5">
        </select></td>
    </tr>
    <tr> 
      <td height="15" colspan="4"><hr size="1" noshade></td>
    </tr>
  </table>
	  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td height="25"><div align="right"><strong>Show by: </strong></div></td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td width="16%" height="25">&nbsp;</td>
      <td width="18%" height="25">College</td>
      <td height="25" colspan="2"><select name="select">
          <option>All</option>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Course</td>
      <td width="29%"><select name="select2">
        </select></td>
      <td width="37%" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Attendant Name</td>
      <td><select name="select6">
        </select></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="49">&nbsp;</td>
      <td height="49">&nbsp;</td>
      <td height="49"><font size="1"><img src="../../images/form_proceed.gif"></font></td>
      <td height="49"><div align="right"><font size="1"><img src="../../images/cancel.gif">click 
          to print list </font></div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" >
    <tr bgcolor="#FFFF9F"> 
      <td height="34" colspan="8"><div align="center"><font color="#0000FF">SUMMARY 
          OF OTHER CHARGES</font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="9%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>SERVICE 
          TYPE CODE</strong></font></div></td>
      <td width="11%"><div align="center"><font color="#000000"><strong><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>SERVICE 
          TYPE NAME</strong></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></strong></font></div></td>
      <td width="16%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>SERVICE 
          SUB-TYPE NAME</strong></font><font color="#000000"><strong></strong></font></div></td>
      <td width="11%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>FEE 
          RATE/ UNIT</strong></font></div></td>
      <td width="7%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>QTY</strong></font></div></td>
      <td width="9%"><div align="center"><font color="#000000"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">AMOUNT 
          DUE </font></strong></font></div></td>
      <td width="20%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>CHARGE 
          POSTED BY</strong></font></div></td>
      <td width="17%" height="24">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right">&nbsp;<img src="../../images/edit.gif"> <img src="../../images/delete.gif"></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

</form>
</body>
</html>
